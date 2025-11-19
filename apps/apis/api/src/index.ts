import Fastify from 'fastify';
import cors from '@fastify/cors';

const PORT = Number(process.env.PORT || 3333);

async function buildServer() {
  const app = Fastify({ logger: true });

  await app.register(cors, { origin: true });

  app.get('/health', async () => ({ status: 'ok', service: 'api', time: new Date().toISOString() }));

  app.get('/', async () => ({ name: 'TeamFlow API', version: '0.1.0' }));

  return app;
}

buildServer()
  .then((app) => app.listen({ port: PORT, host: '0.0.0.0' }))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
