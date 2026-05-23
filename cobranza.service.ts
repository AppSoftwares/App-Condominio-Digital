// backend/src/modules/cobranza/cobranza.service.ts
import { PrismaClient } from '@prisma/client'
import { getDate, getMonth, getYear } from 'date-fns'

const MONTO_PRONTO_PAGO = 15.00  // primeros 5 días del mes
const MONTO_NORMAL      = 20.00  // después del día 5

export class CobranzaService {
  constructor(private readonly prisma: PrismaClient) {}

  /**
   * Calcula el monto según la fecha actual.
   * Días 1-5 del mes → $15 (pronto pago)
   * Días 6+ del mes  → $20
   */
  calcularMonto(fecha = new Date()): number {
    return getDate(fecha) <= 5 ? MONTO_PRONTO_PAGO : MONTO_NORMAL
  }

  /**
   * Genera cuotas del mes para TODAS las casas que aún no tienen una.
   * Se llama desde un cron job el día 1 de cada mes.
   */
  async generarCuotasMensuales(): Promise<{ generadas: number }> {
    const ahora = new Date()
    const mes   = getMonth(ahora) + 1  // date-fns devuelve 0-11
    const anio  = getYear(ahora)

    const casas = await this.prisma.casa.findMany({ select: { id: true } })

    let generadas = 0
    for (const casa of casas) {
      const existe = await this.prisma.cuota.findUnique({
        where: { casaId_mes_anio: { casaId: casa.id, mes, anio } },
      })
      if (!existe) {
        await this.prisma.cuota.create({
          data: { casaId: casa.id, mes, anio, monto: MONTO_PRONTO_PAGO, estado: 'PENDIENTE' },
        })
        generadas++
      }
    }
    return { generadas }
  }

  /**
   * Obtiene el estado de cuenta de una casa:
   * cuotas pagadas, pendientes, morosas y monto actual.
   */
  async estadoCuenta(casaId: number) {
    const ahora = new Date()
    const mesActual = getMonth(ahora) + 1
    const anioActual = getYear(ahora)

    const cuotas = await this.prisma.cuota.findMany({
      where: { casaId },
      include: { pago: { select: { estado: true, fechaPago: true, comprobanteUrl: true } } },
      orderBy: [{ anio: 'desc' }, { mes: 'desc' }],
    })

    // Actualizar morosas: meses anteriores sin pagar
    const morosas = cuotas.filter(
      (c) => c.estado === 'PENDIENTE' && (c.anio < anioActual || (c.anio === anioActual && c.mes < mesActual))
    )
    if (morosas.length > 0) {
      await this.prisma.cuota.updateMany({
        where: { id: { in: morosas.map((c) => c.id) } },
        data: { estado: 'MOROSA' },
      })
    }

    const montoActual = this.calcularMonto()
    const totalDeuda  = cuotas
      .filter((c) => ['PENDIENTE', 'MOROSA'].includes(c.estado))
      .reduce((acc, c) => acc + Number(c.monto), 0)

    return {
      cuotas,
      totalDeuda,
      montoActual,
      esProntoPago: getDate(ahora) <= 5,
      diasRestantesProntoPago: Math.max(0, 5 - getDate(ahora)),
    }
  }

  /**
   * Marcar cuota como morosa manualmente (uso admin).
   */
  async marcarMorosa(cuotaId: number) {
    return this.prisma.cuota.update({
      where: { id: cuotaId },
      data: { estado: 'MOROSA' },
    })
  }
}
