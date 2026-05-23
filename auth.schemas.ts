// backend/src/modules/auth/auth.schemas.ts
// Fastify usa JSON Schema nativo para validación de entrada

export const registerSchema = {
  body: {
    type: 'object',
    required: ['nombre', 'apellido', 'email', 'password', 'casaId'],
    properties: {
      nombre:   { type: 'string', minLength: 2, maxLength: 50 },
      apellido: { type: 'string', minLength: 2, maxLength: 50 },
      email:    { type: 'string', format: 'email' },
      password: { type: 'string', minLength: 8, maxLength: 72 },
      telefono: { type: 'string', minLength: 7, maxLength: 20 },
      casaId:   { type: 'integer', minimum: 1 },
    },
    additionalProperties: false,
  },
}

export const loginSchema = {
  body: {
    type: 'object',
    required: ['email', 'password'],
    properties: {
      email:    { type: 'string', format: 'email' },
      password: { type: 'string', minLength: 1 },
    },
    additionalProperties: false,
  },
}

export const refreshSchema = {
  body: {
    type: 'object',
    required: ['refreshToken'],
    properties: {
      refreshToken: { type: 'string' },
    },
    additionalProperties: false,
  },
}
