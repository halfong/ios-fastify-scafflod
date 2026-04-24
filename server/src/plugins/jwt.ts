import fp from 'fastify-plugin';
import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import jwt, { SignOptions } from 'jsonwebtoken';

export interface JWTPayload {
  id: string;
  email: string;
  role?: string;
  name?: string;
  iat?: number;
  exp?: number;
}

declare module 'fastify' {
  interface FastifyInstance {
    jwt: {
      sign: (payload: Omit<JWTPayload, 'iat' | 'exp'>, expiresIn?: string | number) => string;
      verify: (token: string) => JWTPayload;
    };
    verifyJWT: (request: FastifyRequest, reply: FastifyReply) => Promise<void>;
  }
  interface FastifyRequest {
    user?: JWTPayload;
  }
}

export default fp(async function (fastify: FastifyInstance) {
  const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
  const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

  fastify.decorate('jwt', {
    sign: (payload: Omit<JWTPayload, 'iat' | 'exp'>, expiresIn?: string | number) => {
      const exp = expiresIn || JWT_EXPIRES_IN;
      const options: any = {
        algorithm: 'HS256',
        expiresIn: exp
      };
      return jwt.sign(payload, JWT_SECRET, options);
    },
    verify: (token: string) => {
      try {
        return jwt.verify(token, JWT_SECRET, { algorithms: ['HS256'] }) as JWTPayload;
      } catch (err) {
        throw new Error(`Invalid token: ${err instanceof Error ? err.message : 'Unknown error'}`);
      }
    }
  });

  fastify.decorate('verifyJWT', async function (request: FastifyRequest, reply: FastifyReply) {
    try {
      const authHeader = request.headers.authorization;
      if (!authHeader) {
        return reply.status(401).send({ error: 'Missing authorization header' });
      }
      const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : authHeader;
      const payload = fastify.jwt.verify(token);
      request.user = payload;
    } catch (err) {
      return reply.status(401).send({ error: 'Invalid or expired token' });
    }
  });
});
