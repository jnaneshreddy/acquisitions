import 'dotenv/config';
import { neon } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';
import { drizzle as drizzlePg } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import logger from './logger.js';

// Environment detection
const isDevelopment = process.env.NODE_ENV === 'development';
const isProduction = process.env.NODE_ENV === 'production';
const isTest = process.env.NODE_ENV === 'test';

// Validate DATABASE_URL exists
if (!process.env.DATABASE_URL) {
  logger.error('DATABASE_URL environment variable is required');
  throw new Error('DATABASE_URL environment variable is required');
}

let sql;
let db;

// Configure database connection based on environment
if (isDevelopment || isTest) {
  // Development and Test configuration - use standard PostgreSQL
  const envName = isDevelopment ? 'development' : 'test';
  logger.info(
    `Configuring database for ${envName} environment with PostgreSQL`
  );

  const connectionString = process.env.DATABASE_URL;
  logger.info(
    `Connecting to database: ${connectionString.replace(/:[^:]*@/, ':***@')}`
  );

  // Use standard postgres client for local development and testing
  sql = postgres(connectionString, {
    transform: postgres.camel,
    max: isTest ? 5 : 10, // Fewer connections for tests
  });
  db = drizzlePg(sql, {
    logger: isTest
      ? false
      : {
        logQuery: (query, params) => {
          logger.debug('Database query:', { query, params });
        },
      },
  });
} else if (isProduction) {
  // Production configuration for Neon Cloud
  logger.info(
    'Configuring database for production environment with Neon Cloud'
  );

  // Ensure we have a valid production DATABASE_URL
  if (!process.env.DATABASE_URL.includes('neon.tech')) {
    logger.error(
      'Production DATABASE_URL must be set to a valid Neon Cloud connection string'
    );
    throw new Error(
      'Production DATABASE_URL must be set to a valid Neon Cloud connection string'
    );
  }

  logger.info(
    `Connecting to database: ${process.env.DATABASE_URL.replace(/:[^:@]+@/, ':***@')}`
  );

  // Use Neon serverless for production
  sql = neon(process.env.DATABASE_URL);
  db = drizzle(sql, {
    logger: false, // Disable query logging in production
  });
} else {
  // Default configuration - use Neon
  logger.warn('Unknown environment, using Neon configuration');
  logger.info(
    `Connecting to database: ${process.env.DATABASE_URL.replace(/:[^:@]+@/, ':***@')}`
  );

  sql = neon(process.env.DATABASE_URL);
  db = drizzle(sql, {
    logger: {
      logQuery: (query, params) => {
        logger.debug('Database query:', { query, params });
      },
    },
  });
}

export { sql, db };
export default db;
