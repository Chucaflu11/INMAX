import dotenv from 'dotenv';
dotenv.config();

import { PDS } from '@atproto/pds';

const config = {
  // Server config
  port: 3000,
  publicUrl: process.env.PUBLIC_URL || 'http://localhost:3000',
  serverDid: process.env.SERVER_DID || 'did:web:localhost',
  
  // Database config
  db: {
    dialect: 'postgres',
    url: process.env.DATABASE_URL,
  },
  
  // Blobstore config
  blobstore: {
    provider: 'fs',
    location: process.env.BLOBSTORE_LOCATION || './data/blocks',
  },
  
  // Identity config
  identity: {
    plcUrl: process.env.PLC_URL || 'https://plc.directory',
    signingKey: process.env.REPO_SIGNING_KEY,
    recoveryKey: process.env.RECOVERY_KEY,
    plcRotationKey: process.env.PLC_ROTATION_KEY,
  },
  
  // Auth config
  auth: {
    jwtSecret: process.env.JWT_SECRET,
    adminPassword: process.env.ADMIN_PASSWORD,
  },
};

async function main() {
  try {
    console.log('Starting PDS server with config:', JSON.stringify(config, null, 2));
    const server = await PDS.create(config);
    console.log(`🚀 PDS server running at ${server.url}`);
    
    // Handle clean shutdown
    process.on('SIGTERM', () => server.destroy().finally(() => process.exit(0)));
    process.on('SIGINT', () => server.destroy().finally(() => process.exit(0)));
  } catch (err) {
    console.error('❌ Failed to start server:', err);
    // Log the full error details for more information
    console.error(err.stack);
    process.exit(1);
  }
}

main();