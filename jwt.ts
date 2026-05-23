// backend/src/plugins/jwt.ts
import fp from 'fastify-plugin'
import { FastifyPluginAsync, FastifyRequest, FastifyReply } from 'fastify'
import jwt from 'jsonwebtoken'

export interface JWTPayload {
  sub: number       // usuarioId
  rol: string
  casaId: number | null
}

declare module 'fastify' {
  interface FastifyInstance {
    signAccessToken: (payload: JWTPayload) => string
    signRefreshToken: (payload: JWTPayload) => string
    verifyToken: (token: string) => JWTPayload
    authenticate: (req: FastifyRequest, reply: FastifyReply) => Promise<void>
  }
  interface FastifyRequest {
    user: JWTPayload
  }
}

const jwtPlugin: FastifyPluginAsync = fp(async (fastify) => {
  const ACCESS_SECRET  = process.env.JWT_ACCESS_SECRET!
  const REFRESH_SECRET = process.env.JWT_REFRESH_SECRET!

  fastify.decorate('signAccessToken', (payload: JWTPayload) =>
    jwt.sign(payload, ACCESS_SECRET, { expiresIn: '15m' })
  )

  fastify.decorate('signRefreshToken', (payload: JWTPayload) =>
    jwt.sign(payload, REFRESH_SECRET, { expiresIn: '30d' })
  )

  fastify.decorate('verifyToken', (token: string) =>
    jwt.verify(token, ACCESS_SECRET) as JWTPayload
  )

  // Hook reutilizable para rutas protegidas
  fastify.decorate('authenticate', async (req: FastifyRequest, reply: FastifyReply) => {
    const authHeader = req.headers.authorization
    if (!authHeader?.startsWith('Bearer ')) {
      return reply.status(401).send({ error: 'Token requerido' })
    }
    try {
      const token = authHeader.split(' ')[1]
      req.user = fastify.verifyToken(token)
    } catch {
      return reply.status(401).send({ error: 'Token inválido o expirado' })
    }
  })
})

export default jwtPlugin
