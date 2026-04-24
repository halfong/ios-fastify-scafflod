import { describe, it, expect } from "vitest";
import Fastify from "fastify";
import { healthRoutes } from "../routes/health.js";

describe("health route", () => {
  it("returns 200 with ok status", async () => {
    const app = Fastify();
    await app.register(healthRoutes);

    const response = await app.inject({
      method: "GET",
      url: "/health",
    });

    expect(response.statusCode).toBe(200);
    const body = response.json<{ status: string }>();
    expect(body.status).toBe("ok");
  });
});
