'use strict'

import fp from 'fastify-plugin'
import { FastifyInstance } from 'fastify'
import rateLimit from '@fastify/rate-limit'

export default fp(async function (fastify: FastifyInstance) {
  await fastify.register(rateLimit, { max: 120, timeWindow: '1 minute' })
})
