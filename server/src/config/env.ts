/**
 * Environment configuration loader.
 * Reads from process.env (populated via .env file in development).
 */

export interface AppEnv {
  PORT: number;
  NODE_ENV: string;
  LOG_LEVEL: string;
}

function loadEnv(): AppEnv {
  return {
    // Falls back to 3000 if PORT env var is unset and the template token hasn't
    // been replaced yet (Number("3000") === NaN).
    PORT: Number(process.env["PORT"] ?? "3000") || 3000,
    NODE_ENV: process.env["NODE_ENV"] ?? "development",
    LOG_LEVEL: process.env["LOG_LEVEL"] ?? "info",
  };
}

export const env: AppEnv = loadEnv();
