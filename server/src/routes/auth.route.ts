import type { FastifyInstance } from 'fastify';
import { ZodTypeProvider } from 'fastify-type-provider-zod';
import { z } from 'zod';
import $db from '../utils/db.service';
import $authService from '../services/auth.service';

const userSchema = z.object({
  id: z.string(),
  email: z.string(),
  name: z.string().nullish(),
  role: z.string().optional(),
});

const tokenResponseSchema = z.object({
  token: z.string(),
  expiry: z.date(),
  user: userSchema,
});

export default async function (fastify: FastifyInstance) {
  const f = fastify.withTypeProvider<ZodTypeProvider>();

  // Sign in with email + password
  f.post('/auth/login', {
    schema: {
      tags: ['Auth'],
      description: 'Sign in with email and password',
      body: z.object({ email: z.string().email(), password: z.string() }),
      response: { 200: tokenResponseSchema },
    },
  }, async (req, reply) => {
    const { email, password } = req.body;
    const user = await $authService.verifyEmailPassword(email, password);
    if (!user) throw '401:Invalid credentials';
    const token = fastify.jwt.sign({ id: user.id, email: user.email, role: user.role, name: user.name ?? undefined });
    const expiry = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
    return { token, expiry, user: { id: user.id, email: user.email, name: user.name, role: user.role } };
  });

  // Sign in with Apple identity token (Sign in with Apple)
  f.post('/auth/apple', {
    schema: {
      tags: ['Auth'],
      description: 'Sign in with Apple identity token',
      body: z.object({
        identityToken: z.string(),
        email: z.string().email().optional(),
        name: z.string().optional(),
      }),
      response: { 200: tokenResponseSchema },
    },
  }, async (req) => {
    const { identityToken, email, name } = req.body;
    const user = await $authService.signInWithApple({ identityToken, email, name });
    const token = fastify.jwt.sign({ id: user.id, email: user.email, role: user.role, name: user.name ?? undefined });
    const expiry = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
    return { token, expiry, user: { id: user.id, email: user.email, name: user.name, role: user.role } };
  });

  // Get the currently authenticated user
  f.get('/auth', {
    onRequest: [fastify.verifyJWT],
    schema: {
      tags: ['Auth'],
      description: 'Get the currently authenticated user',
      security: [{ bearerAuth: [] }],
      response: { 200: userSchema },
    },
  }, async (req) => {
    const user = req.user!;
    return { id: user.id, email: user.email, name: user.name, role: user.role };
  });

  // Refresh the JWT token (issues a new token with a fresh expiry)
  f.get('/auth/refresh', {
    onRequest: [fastify.verifyJWT],
    schema: {
      tags: ['Auth'],
      description: 'Refresh the JWT token',
      security: [{ bearerAuth: [] }],
      response: { 200: tokenResponseSchema },
    },
  }, async (req) => {
    const user = req.user!;
    const newToken = fastify.jwt.sign({ id: user.id, email: user.email, role: user.role });
    return {
      token: newToken,
      expiry: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      user: { id: user.id, email: user.email, name: user.name, role: user.role },
    };
  });

  // Soft-delete (deactivate) the current user's account
  f.delete('/auth', {
    onRequest: [fastify.verifyJWT],
    schema: {
      tags: ['Auth'],
      description: 'Deactivate the authenticated user account',
      security: [{ bearerAuth: [] }],
      response: { 200: z.object({ ok: z.boolean() }) },
    },
  }, async (req) => {
    const { id } = req.user!;
    const user = await $db.user.findUnique({ where: { id } });
    if (!user) throw '404:User not found';
    await $db.user.update({ where: { id }, data: { active: false } });
    return { ok: true };
  });
}
