// When using this file standalone, replace '@db/client' with the path to your generated Prisma client.
// In the Vocano monorepo, @db/client is mapped to src/prisma/client/client via tsconfig paths.
import { PrismaClient } from '@db/client';
import { PrismaMariaDb } from '@prisma/adapter-mariadb';

import dotenv from 'dotenv';
dotenv.config();

if (!process.env.DATABASE_URL) {
  throw new Error('DATABASE_URL is not set');
}

// Parse DATABASE_URL to create adapter with proper pool configuration
const dbUrl = new URL(process.env.DATABASE_URL);
const adapter = new PrismaMariaDb({
  host: dbUrl.hostname,
  port: dbUrl.port ? parseInt(dbUrl.port) : 3306,
  user: dbUrl.username,
  password: dbUrl.password,
  database: dbUrl.pathname.slice(1),
  connectionLimit: 10,
  acquireTimeout: 30000,  // 30 seconds timeout
  idleTimeout: 60000,     // Close idle connections after 60 seconds
  allowPublicKeyRetrieval: true,
});

const $db = new PrismaClient({ adapter });

export default $db;
