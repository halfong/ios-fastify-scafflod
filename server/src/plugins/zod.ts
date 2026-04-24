import { FastifyInstance } from 'fastify';
import fp from 'fastify-plugin'
import {
  validatorCompiler,
  serializerCompiler
} from 'fastify-type-provider-zod';

export default fp(async function (fastify: FastifyInstance) {
  fastify.setValidatorCompiler(validatorCompiler);
  fastify.setSerializerCompiler(serializerCompiler);
})
