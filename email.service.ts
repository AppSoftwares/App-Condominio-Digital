// backend/src/modules/cobranza/email.service.ts
import { Resend } from 'resend'

const resend = new Resend(process.env.RESEND_API_KEY!)
const FROM   = process.env.EMAIL_FROM ?? 'noreply@tucondominio.com'

export class EmailService {
  // ── Confirmación de pago recibido ───────────────────────────
  async enviarConfirmacionPago(params: {
    email: string
    nombre: string
    mes: string
    anio: number
    monto: number
    comprobanteUrl: string
  }) {
    await resend.emails.send({
      from: FROM,
      to: params.email,
      subject: `✅ Pago de condominio recibido — ${params.mes} ${params.anio}`,
      html: `
        <div style="font-family:sans-serif;max-width:480px;margin:auto">
          <h2 style="color:#1A6B3C">Pago recibido</h2>
          <p>Hola <strong>${params.nombre}</strong>,</p>
          <p>Recibimos tu comprobante de pago para el mes de <strong>${params.mes} ${params.anio}</strong>.</p>
          <table style="width:100%;border-collapse:collapse;margin:16px 0">
            <tr style="background:#f4f4f4">
              <td style="padding:8px 12px">Monto</td>
              <td style="padding:8px 12px;font-weight:bold">$${params.monto.toFixed(2)}</td>
            </tr>
            <tr>
              <td style="padding:8px 12px">Estado</td>
              <td style="padding:8px 12px;color:#1A6B3C">Pendiente de validación</td>
            </tr>
          </table>
          <p>
            <a href="${params.comprobanteUrl}" 
               style="background:#1A6B3C;color:#fff;padding:10px 20px;border-radius:6px;text-decoration:none">
              Ver comprobante
            </a>
          </p>
          <p style="color:#888;font-size:12px">
            El administrador validará tu pago en las próximas 24 horas.
          </p>
        </div>
      `,
    })
  }

  // ── Notificación de pago aprobado ───────────────────────────
  async enviarPagoAprobado(params: {
    email: string
    nombre: string
    mes: string
    anio: number
    monto: number
  }) {
    await resend.emails.send({
      from: FROM,
      to: params.email,
      subject: `🎉 Pago aprobado — ${params.mes} ${params.anio}`,
      html: `
        <div style="font-family:sans-serif;max-width:480px;margin:auto">
          <h2 style="color:#1A6B3C">Pago aprobado ✓</h2>
          <p>Hola <strong>${params.nombre}</strong>,</p>
          <p>Tu pago de condominio por <strong>$${params.monto.toFixed(2)}</strong> 
             correspondiente a <strong>${params.mes} ${params.anio}</strong> fue aprobado.</p>
          <p style="color:#1A6B3C;font-weight:bold">¡Gracias por pagar a tiempo!</p>
        </div>
      `,
    })
  }

  // ── Recordatorio de mora ─────────────────────────────────────
  async enviarRecordatorioMora(params: {
    email: string
    nombre: string
    deuda: number
    cuotasPendientes: number
    convenioUrl?: string
  }) {
    await resend.emails.send({
      from: FROM,
      to: params.email,
      subject: `⚠️ Recordatorio de pago pendiente — Condominio`,
      html: `
        <div style="font-family:sans-serif;max-width:480px;margin:auto">
          <h2 style="color:#c0392b">Pago pendiente</h2>
          <p>Hola <strong>${params.nombre}</strong>,</p>
          <p>Te recordamos que tienes <strong>${params.cuotasPendientes} cuota(s)</strong> 
             pendientes de pago por un total de <strong>$${params.deuda.toFixed(2)}</strong>.</p>
          <p>Por favor realiza tu pago a través de la app para evitar recargos adicionales.</p>
          ${params.convenioUrl ? `
          <p>
            <a href="${params.convenioUrl}"
               style="background:#c0392b;color:#fff;padding:10px 20px;border-radius:6px;text-decoration:none">
              Solicitar convenio de pago
            </a>
          </p>` : ''}
          <p style="color:#888;font-size:12px">
            Si ya realizaste tu pago, por favor ignora este mensaje.
          </p>
        </div>
      `,
    })
  }
}
