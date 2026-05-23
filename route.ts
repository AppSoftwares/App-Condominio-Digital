import { NextResponse } from 'next/server';
import prisma from '@/lib/prisma'; // Asegúrate de que PrismaClient esté generado

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { method, reference, houseId, userId } = body;

    // 1. Seguridad: Verificar usuario y rol
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user || (user.role !== 'PROPIETARIO' && user.role !== 'ADMIN')) {
      return NextResponse.json(
        { error: 'No autorizado para registrar pagos.' },
        { status: 403 }
      );
    }

    // 2. Lógica de Negocio: Cálculo de cuota según el día del mes
    const today = new Date();
    const dayOfMonth = today.getDate();
    // Si es antes o igual al día 5: $15, de lo contrario $20
    const finalAmount = dayOfMonth <= 5 ? 15.00 : 20.00;

    // 3. Registro en DB
    const newPayment = await prisma.payment.create({
      data: {
        amount: finalAmount,
        method, // PAGO_MOVIL, ZELLE, BINANCE, EFECTIVO
        reference,
        status: 'PENDIENTE',
        houseId: parseInt(houseId),
        createdAt: today,
      },
    });

    return NextResponse.json({
      message: `Pago registrado por $${finalAmount}. Pendiente de verificación.`,
      payment: newPayment
    }, { status: 201 });

  } catch (error) {
    console.error('Error en API de pagos:', error);
    return NextResponse.json({ error: 'Error interno al procesar el pago' }, { status: 500 });
  }
}