import Fastify from "fastify";
import cors from "@fastify/cors";
import { healthRoutes } from "./routes/health.js";
import { exampleRoutes } from "./routes/example.js";
import { env } from "./config/env.js";

const server = Fastify({
  logger: {
    level: env.LOG_LEVEL,
  },
});

// Plugins
await server.register(cors, {
  origin: true,
});

// Routes
await server.register(healthRoutes);
await server.register(exampleRoutes, { prefix: "/api/v1" });

// Start
try {
  await server.listen({ port: env.PORT, host: "0.0.0.0" });
  console.log(`🚀  Server listening on port ${env.PORT}`);
} catch (err) {
  server.log.error(err);
  process.exit(1);
}
