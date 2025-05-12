import { createServer } from '@atproto/pds';

const main = async () => {
  const server = await createServer({
    port: 3000,
    hostname: 'localhost',
    dbPostgresUrl: process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/atproto',
    inviteRequired: false,
    adminPassword: process.env.ADMIN_PASSWORD || 'admin',
    serviceDid: 'did:web:your-domain.com'
  });

  await server.start();
  console.log(`PDS server running at http://localhost:3000`);
};

main().catch(err => {
  console.error(err);
  process.exit(1);
});