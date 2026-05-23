// backend/src/modules/auth/auth.routes.ts
import { FastifyInstance } from 'fastify'
import bcrypt from 'bcrypt'
import { addDays } from 'date-fns'
import { registerSchema, loginSchema, refreshSchema } from './auth.schemas'

export default async function authRoutes(fastify: FastifyInstance) {
  const { prisma } = fastify

  // ----------------------------------------------------------
  // GET /auth/ubicacion — datos para el registro jerárquico
  // Retorna árbol: Urbanización > Etapas > Conjuntos > Casas
  // ----------------------------------------------------------
  fastify.get('/ubicacion', async (_req, reply) => {
    const data = await prisma.urbanizacion.findMany({
      include: {
        etapas: {
          include: {
            conjuntos: {
              include: { casas: { select: { id: true, numero: true } } },
            },
          },
        },
      },
    })
    return reply.send(data)
  })

  // ----------------------------------------------------------
  // POST /auth/registro
  // ----------------------------------------------------------
  fastify.post('/registro', { schema: registerSchema }, async (req, reply) => {
    const { nombre, apellido, email, password, telefono, casaId, rol } = req.body as any

    // Verificar que la casa exista
    const casa = await prisma.casa.findUnique({ where: { id: casaId } })
    if (!casa) return reply.status(400).send({ error: 'Casa no encontrada' })

    // Máximo 2 usuarios por casa (propietario + copropietario)
    const usuariosCasa = await prisma.usuario.count({
      where: {
        casaId,
        estado: { not: 'INACTIVO' },
        rol: { in: ['PROPIETARIO', 'COPROPIETARIO'] },
      },
    })
    if (usuariosCasa >= 2) {
      return reply.status(400).send({ error: 'La casa ya tiene el máximo de usuarios registrados' })
    }

    // Email único
    const existe = await prisma.usuario.findUnique({ where: { email } })
    if (existe) return reply.status(400).send({ error: 'Email ya registrado' })

    const passwordHash = await bcrypt.hash(password, 12)
    const rolFinal = usuariosCasa === 0 ? 'PROPIETARIO' : 'COPROPIETARIO'

    const usuario = await prisma.usuario.create({
      data: {
        nombre,
        apellido,
        email,
        telefono,
        passwordHash,
        casaId,
        rol: rolFinal,
        estado: 'PENDIENTE', // admin debe aprobar
      },
      select: { id: true, nombre: true, apellido: true, email: true, rol: true, estado: true },
    })

    return reply.status(201).send({
      message: 'Registro exitoso. Pendiente de aprobación por el administrador.',
      usuario,
    })
  })

  // ----------------------------------------------------------
  // POST /auth/login
  // ----------------------------------------------------------
  fastify.post('/login', { schema: loginSchema }, async (req, reply) => {
    const { email, password } = req.body as any

    const usuario = await prisma.usuario.findUnique({
      where: { email },
      select: {
        id: true, nombre: true, apellido: true, email: true,
        passwordHash: true, rol: true, estado: true, casaId: true,
      },
    })

    if (!usuario) return reply.status(401).send({ error: 'Credenciales inválidas' })
    if (usuario.estado === 'INACTIVO') return reply.status(403).send({ error: 'Usuario desactivado' })
    if (usuario.estado === 'PENDIENTE') return reply.status(403).send({ error: 'Cuenta pendiente de aprobación' })

    const passwordOk = await bcrypt.compare(password, usuario.passwordHash)
    if (!passwordOk) return reply.status(401).send({ error: 'Credenciales inválidas' })

    const payload = { sub: usuario.id, rol: usuario.rol, casaId: usuario.casaId }
    const accessToken  = fastify.signAccessToken(payload)
    const refreshToken = fastify.signRefreshToken(payload)

    // Guardar refresh token en BD
    await prisma.refreshToken.create({
      data: {
        token: refreshToken,
        usuarioId: usuario.id,
        expiresAt: addDays(new Date(), 30),
      },
    })

    const { passwordHash: _, ...usuarioSafe } = usuario

    return reply.send({ accessToken, refreshToken, usuario: usuarioSafe })
  })

  // ----------------------------------------------------------
  // POST /auth/refresh — renovar access token
  // ----------------------------------------------------------
  fastify.post('/refresh', { schema: refreshSchema }, async (req, reply) => {
    const { refreshToken } = req.body as any

    const stored = await prisma.refreshToken.findUnique({
      where: { token: refreshToken },
      include: { usuario: { select: { id: true, rol: true, casaId: true, estado: true } } },
    })

    if (!stored || stored.expiresAt < new Date()) {
      return reply.status(401).send({ error: 'Refresh token inválido o expirado' })
    }

    if (stored.usuario.estado !== 'ACTIVO') {
      return reply.status(403).send({ error: 'Usuario desactivado' })
    }

    const payload = {
      sub: stored.usuario.id,
      rol: stored.usuario.rol,
      casaId: stored.usuario.casaId,
    }

    const newAccessToken = fastify.signAccessToken(payload)

    return reply.send({ accessToken: newAccessToken })
  })

  // ----------------------------------------------------------
  // POST /auth/google — Login/Registro con Google
  // ----------------------------------------------------------
  fastify.post('/google', async (req, reply) => {
    const { idToken } = req.body as any
    // Aquí deberías:
    // 1. Verificar el token con google-auth-library
    // 2. Obtener el email del usuario
    // 3. Buscar si el usuario existe en la BD
    // 4. Si no existe, podrías crearlo (pero recuerda que necesitas casaId)
    //    O retornar un estado indicando que debe completar su perfil/casa.

    // Simplificación para ejemplo:
    return reply.status(501).send({ error: 'Implementación de verificación de Google pendiente en backend' })
  })

  // ----------------------------------------------------------
  // POST /auth/logout — revocar refresh token
  // ----------------------------------------------------------
  fastify.post('/logout', { preHandler: [fastify.authenticate] }, async (req, reply) => {
    const { refreshToken } = req.body as any
    await prisma.refreshToken.deleteMany({ where: { token: refreshToken } })
    return reply.send({ message: 'Sesión cerrada' })
  })
}
