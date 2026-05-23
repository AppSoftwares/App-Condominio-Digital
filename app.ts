// backend/src/app.ts
import Fastify from 'fastify'
import cors from '@fastify/cors'
import rateLimit from '@fastify/rate-limit'
import multipart from '@fastify/multipart'

import prismaPlugin from './plugins/prisma'
import jwtPlugin from './plugins/jwt'
import authRoutes from './modules/auth/auth.routes'

const fastify = Fastify({
  logger: {
    level: process.env.NODE_ENV === 'production' ? 'warn' : 'info',
    transport: process.env.NODE_ENV !== 'production'
      ? { target: 'pino-pretty', options: { colorize: true } }
      : undefined,
  },
})

async function bootstrap() {
  // ---- Seguridad ----
  await fastify.register(cors, {
    origin: [
      process.env.WEB_URL ?? 'http://localhost:3000',
    ],
    credentials: true,
  })

  await fastify.register(rateLimit, {
    global: true,
    max: 100,
    timeWindow: '1 minute',
  })

  // ---- Uploads (comprobantes de pago) ----
  await fastify.register(multipart, {
    limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB máx
  })

  // ---- Plugins internos ----
  await fastify.register(prismaPlugin)
  await fastify.register(jwtPlugin)

  // ---- Rutas ----
  await fastify.register(authRoutes, { prefix: '/auth' })

  // Futuras rutas (se irán agregando por módulo):
  // await fastify.register(cuotasRoutes,    { prefix: '/cuotas' })
  // await fastify.register(reservasRoutes,  { prefix: '/reservas' })
  // await fastify.register(gastosRoutes,    { prefix: '/gastos' })
  // await fastify.register(chatRoutes,      { prefix: '/chat' })
  // await fastify.register(votacionesRoutes,{ prefix: '/votaciones' })

  // ---- Health check ----
  fastify.get('/health', async () => ({ status: 'ok', ts: new Date().toISOString() }))

  const port = Number(process.env.PORT ?? 4000)
  await fastify.listen({ port, host: '0.0.0.0' })
}

bootstrap().catch((err) => {
  fastify.log.error(err)
  process.exit(1)
})
