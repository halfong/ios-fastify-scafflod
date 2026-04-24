import { FastifyInstance } from 'fastify';
import { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';

export default async function (fastify: FastifyInstance) {
  const f = fastify.withTypeProvider<ZodTypeProvider>();

  f.get('/health', {
    config: {
      rateLimit: { max: 2, timeWindow: '1 minute' },
    },
    schema: {
      tags: ['Health'],
      description: 'Health check endpoint',
      response: {
        200: z.object({
          status: z.literal('ok'),
          timestamp: z.string(),
        }),
      },
    },
  }, async () => {
    return { status: 'ok' as const, timestamp: new Date().toISOString() };
  });

  f.get('/', {
    schema: {
      tags: ['Health'],
      description: 'API root — version information',
      response: {
        200: z.object({
          name: z.string(),
          version: z.string(),
          status: z.string(),
        }),
      },
    },
  }, async () => {
    return {
      name: process.env.API_TITLE || 'Fastify API',
      version: process.env.API_VERSION || '1.0.0',
      status: 'running',
    };
  });
}
