import fp from 'fastify-plugin';
import { FastifyInstance } from 'fastify';
import { ZodError } from 'zod';


export default fp(async function (fastify: FastifyInstance) {

  fastify.setErrorHandler((error, request, reply) => {

    console.error(error);

    let statusCode = 500;
    let errorMessage = 'Unexpected server error';

    if (error instanceof ZodError) {
      statusCode = 400;
      errorMessage = 'Validation error';
    } else if (typeof error === 'string') {
      errorMessage = error;
      // Custom error format: "statusCode:message"
      if (errorMessage.match(/^\d{3}\:/)) {
        const [code, ...messageParts] = errorMessage.split(':');
        statusCode = parseInt(code, 10);
        errorMessage = messageParts.join(':').trim();
      }
    } else if (error instanceof Error) {
      errorMessage = error.message;
    }

    return reply.status(statusCode).send({
      message: errorMessage,
    });
  });
});
