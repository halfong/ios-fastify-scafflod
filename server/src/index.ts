import Fastify, { FastifyInstance } from 'fastify';
import autoload from '@fastify/autoload';
import { join } from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import $db from './utils/db.service';
import dotenv from 'dotenv';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config();
process.env.TZ = 'UTC';

const FASTIFY_DEBUG = process.env.FASTIFY_DEBUG === 'true';
const FASTIFY_BODY_LIMIT = process.env.FASTIFY_BODY_LIMIT ? parseInt(process.env.FASTIFY_BODY_LIMIT, 10) : 1048576 * 2;
const FASTIFY_PORT = process.env.FASTIFY_PORT ? parseInt(process.env.FASTIFY_PORT, 10) : 3000;
const FASTIFY_HOST = process.env.FASTIFY_HOST || '127.0.0.1';

export async function createApp(options: {
  logger: boolean;
  bodyLimit: number;
}): Promise<FastifyInstance> {
  const app: FastifyInstance = Fastify({
    logger: options.logger,
    bodyLimit: options.bodyLimit,
    disableRequestLogging: true,
  });

  await app.register(autoload, { dir: join(__dirname, 'plugins') });
  await app.register(autoload, { dir: join(__dirname, 'routes') });

  app.addHook('onClose', async () => {
    await $db.$disconnect();
  });

  return app;
}

const start = async () => {
  try {
    const server = await createApp({
      logger: FASTIFY_DEBUG,
      bodyLimit: FASTIFY_BODY_LIMIT,
    });
    await server.listen({ port: FASTIFY_PORT, host: FASTIFY_HOST });
    console.log(`Server listening at http://${FASTIFY_HOST}:${FASTIFY_PORT}`);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
};

start();
