// backend/src/modules/cobranza/cobranza.routes.ts
import { FastifyInstance } from 'fastify'
import { format } from 'date-fns'
import { es } from 'date-fns/locale'
import { requireRole } from '../../middleware/role.guard'
import { CobranzaService } from './cobranza.service'
import { StorageService } from './storage.service'
import { EmailService } from './email.service'

export default async function cobranzaRoutes(fastify: FastifyInstance) {
  const { prisma } = fastify
  const cobranzaSvc = new CobranzaService(prisma)
  const storageSvc  = new StorageService()
  const emailSvc    = new EmailService()

  // ── GET /cobranza/estado-cuenta ──────────────────────────────
  // Propietario ve su estado de cuenta con caché Redis (5 min)
  fastify.get('/estado-cuenta', {
    preHandler: [fastify.authenticate],
  }, async (req, reply) => {
    const casaId = req.user.casaId
    if (!casaId) return reply.status(400).send({ error: 'Usuario sin casa asignada' })

    // Cache Redis
    const cacheKey = `estado-cuenta:${casaId}`
    const cached   = await fastify.redis?.get(cacheKey)
    if (cached) return reply.send(JSON.parse(cached))

    const data = await cobranzaSvc.estadoCuenta(casaId)

    await fastify.redis?.setex(cacheKey, 300, JSON.stringify(data)) // TTL 5 min
    return reply.send(data)
  })

  // ── POST /cobranza/pagar ─────────────────────────────────────
  // Propietario sube comprobante + monto
  fastify.post('/pagar', {
    preHandler: [fastify.authenticate],
  }, async (req, reply) => {
    const casaId = req.user.casaId
    if (!casaId) return reply.status(400).send({ error: 'Sin casa asignada' })

    // Parsear multipart (imagen + campos)
    const parts = req.parts()
    let cuotaId: number | undefined
    let monto: number | undefined
    let file: any

    for await (const part of parts) {
      if (part.type === 'field') {
        if (part.fieldname === 'cuotaId') cuotaId = Number(part.value)
        if (part.fieldname === 'monto')   monto   = Number(part.value)
      } else {
        file = part
      }
    }

    if (!cuotaId || !monto || !file) {
      return reply.status(400).send({ error: 'Faltan campos: cuotaId, monto, archivo' })
    }

    // Verificar que la cuota pertenece a la casa
    const cuota = await prisma.cuota.findFirst({
      where: { id: cuotaId, casaId, estado: { in: ['PENDIENTE', 'MOROSA'] } },
    })
    if (!cuota) return reply.status(404).send({ error: 'Cuota no encontrada o ya pagada' })

    // Subir comprobante
    const comprobanteUrl = await storageSvc.subirComprobante(file, casaId)

    // Crear registro de pago
    const pago = await prisma.pago.create({
      data: {
        cuotaId,
        usuarioId: req.user.sub,
        monto,
        comprobanteUrl,
        fechaPago: new Date(),
        estado: 'PENDIENTE_VALIDACION',
      },
    })

    // Invalidar cache
    await fastify.redis?.del(`estado-cuenta:${casaId}`)

    // Notificar al propietario por email
    const usuario = await prisma.usuario.findUnique({
      where: { id: req.user.sub },
      select: { email: true, nombre: true },
    })
    if (usuario) {
      const nombreMes = format(new Date(cuota.anio, cuota.mes - 1), 'MMMM', { locale: es })
      await emailSvc.enviarConfirmacionPago({
        email: usuario.email,
        nombre: usuario.nombre,
        mes: nombreMes,
        anio: cuota.anio,
        monto,
        comprobanteUrl,
      }).catch(() => {}) // No bloquear si el email falla
    }

    return reply.status(201).send({ pago, message: 'Comprobante recibido. Pendiente de validación.' })
  })

  // ── PATCH /cobranza/validar/:pagoId ─────────────────────────
  // Solo ADMINISTRADOR puede aprobar o rechazar
  fastify.patch('/validar/:pagoId', {
    preHandler: [fastify.authenticate, requireRole('ADMINISTRADOR')],
  }, async (req, reply) => {
    const { pagoId } = req.params as { pagoId: string }
    const { accion, notas } = req.body as { accion: 'APROBAR' | 'RECHAZAR'; notas?: string }

    const pago = await prisma.pago.findUnique({
      where: { id: Number(pagoId) },
      include: {
        cuota: true,
        usuario: { select: { email: true, nombre: true } },
      },
    })
    if (!pago) return reply.status(404).send({ error: 'Pago no encontrado' })

    const estadoPago  = accion === 'APROBAR' ? 'APROBADO' : 'RECHAZADO'
    const estadoCuota = accion === 'APROBAR' ? 'PAGADA'   : pago.cuota.estado

    await prisma.$transaction([
      prisma.pago.update({
        where: { id: pago.id },
        data: { estado: estadoPago, notas, validadoEn: new Date() },
      }),
      prisma.cuota.update({
        where: { id: pago.cuotaId },
        data: { estado: estadoCuota },
      }),
    ])

    // Invalidar cache de la casa
    await fastify.redis?.del(`estado-cuenta:${pago.cuota.casaId}`)

    // Email al propietario si fue aprobado
    if (accion === 'APROBAR') {
      const nombreMes = format(new Date(pago.cuota.anio, pago.cuota.mes - 1), 'MMMM', { locale: es })
      await emailSvc.enviarPagoAprobado({
        email: pago.usuario.email,
        nombre: pago.usuario.nombre,
        mes: nombreMes,
        anio: pago.cuota.anio,
        monto: Number(pago.monto),
      }).catch(() => {})
    }

    return reply.send({ message: `Pago ${estadoPago.toLowerCase()}` })
  })

  // ── GET /cobranza/pendientes-validacion ──────────────────────
  // Admin ve todos los pagos que esperan validación
  fastify.get('/pendientes-validacion', {
    preHandler: [fastify.authenticate, requireRole('ADMINISTRADOR', 'CONTADOR')],
  }, async (_req, reply) => {
    const pagos = await prisma.pago.findMany({
      where: { estado: 'PENDIENTE_VALIDACION' },
      include: {
        cuota: { include: { casa: { include: { conjunto: true } } } },
        usuario: { select: { nombre: true, apellido: true, email: true } },
      },
      orderBy: { creadoEn: 'asc' },
    })
    return reply.send(pagos)
  })

  // ── POST /cobranza/recordatorios ─────────────────────────────
  // Cron job mensual — enviar recordatorios a morosos
  fastify.post('/recordatorios', {
    preHandler: [fastify.authenticate, requireRole('ADMINISTRADOR')],
  }, async (_req, reply) => {
    const morosos = await prisma.usuario.findMany({
      where: {
        rol: { in: ['PROPIETARIO', 'COPROPIETARIO'] },
        estado: 'ACTIVO',
        casa: {
          cuotas: { some: { estado: { in: ['PENDIENTE', 'MOROSA'] } } },
        },
      },
      include: {
        casa: {
          include: {
            cuotas: {
              where: { estado: { in: ['PENDIENTE', 'MOROSA'] } },
            },
          },
        },
      },
    })

    let enviados = 0
    for (const usuario of morosos) {
      if (!usuario.casa) continue
      const deuda = usuario.casa.cuotas.reduce((acc, c) => acc + Number(c.monto), 0)
      await emailSvc.enviarRecordatorioMora({
        email: usuario.email,
        nombre: usuario.nombre,
        deuda,
        cuotasPendientes: usuario.casa.cuotas.length,
      }).catch(() => {})
      enviados++
    }

    return reply.send({ enviados, message: `Recordatorios enviados a ${enviados} propietarios` })
  })

  // ── POST /cobranza/generar-cuotas ────────────────────────────
  // Cron job día 1 de cada mes
  fastify.post('/generar-cuotas', {
    preHandler: [fastify.authenticate, requireRole('ADMINISTRADOR')],
  }, async (_req, reply) => {
    const resultado = await cobranzaSvc.generarCuotasMensuales()
    return reply.send(resultado)
  })
}
