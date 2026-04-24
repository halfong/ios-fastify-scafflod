'use strict'

import fp from 'fastify-plugin'
import { FastifyInstance } from 'fastify'
import Cron from 'fastify-cron'

export default fp(async function (fastify: FastifyInstance) {
  await fastify.register(Cron, {
    jobs: [
      {
        cronTime: '0 8 * * *',
        onTick: async () => {
          // Add scheduled tasks here
        },
        start: true,
      }
    ]
  })

  fastify.addHook('onClose', async () => {
    if (fastify.cron?.jobs) {
      fastify.cron.jobs.forEach((job: any) => {
        if (job.running) {
          job.stop();
        }
      });
    }
  });
})
