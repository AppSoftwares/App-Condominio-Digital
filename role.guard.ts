// backend/src/middleware/role.guard.ts
import { FastifyRequest, FastifyReply } from 'fastify'

type Rol = 'ADMINISTRADOR' | 'CONTADOR' | 'PROPIETARIO' | 'COPROPIETARIO'

/**
 * Uso:
 *   fastify.get('/ruta', {
 *     preHandler: [fastify.authenticate, requireRole('ADMINISTRADOR')]
 *   }, handler)
 */
export function requireRole(...roles: Rol[]) {
  return async (req: FastifyRequest, reply: FastifyReply) => {
    if (!req.user) {
      return reply.status(401).send({ error: 'No autenticado' })
    }
    if (!roles.includes(req.user.rol as Rol)) {
      return reply.status(403).send({ error: 'Sin permisos para esta acción' })
    }
  }
}
