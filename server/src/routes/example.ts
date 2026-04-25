import { FastifyPluginAsync } from "fastify";
import type { ExampleItem, ExampleListResponse } from "../types/api.js";

/**
 * Example resource routes — replace or extend with your real API.
 *
 * GET  /api/v1/examples        list examples
 * GET  /api/v1/examples/:id    get one example
 */
export const exampleRoutes: FastifyPluginAsync = async (fastify) => {
  // In-memory stub — swap with a real database/repository layer.
  const items: ExampleItem[] = [
    { id: "1", title: "First example", createdAt: new Date().toISOString() },
    { id: "2", title: "Second example", createdAt: new Date().toISOString() },
  ];

  fastify.get<{ Reply: ExampleListResponse }>("/examples", async () => {
    return { data: items, total: items.length };
  });

  fastify.get<{ Params: { id: string }; Reply: ExampleItem | { error: string } }>(
    "/examples/:id",
    async (request, reply) => {
      const item = items.find((i) => i.id === request.params.id);
      if (!item) {
        return reply.code(404).send({ error: "Not found" });
      }
      return item;
    }
  );
};
