import express from 'express';
import logger from '#config/logger.js';
import helmet from 'helmet';
import morgan from 'morgan';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import authRouts from '#routes/auth.routs.js';
import usersRoutes from '#routes/users.routes.js';
import securityMiddleware from '#middleware/security.middleware.js';

const app = express();

// Trust proxy for proper IP detection (required for Arcjet)
app.set('trust proxy', true);

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

app.use(
  morgan('combined', {
    stream: {
      write: message => logger.info(message.trim()),
    },
  })
);

// Apply Arcjet security middleware globally
app.use(securityMiddleware);

app.get('/', (req, res) => {
  logger.info('hello from acquisitions');
  res.status(200).send('hello from acquisitions');
});

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
  });
});

app.get('/api', (req, res) => {
  res.status(200).json({ message: 'acquisitions is running' });
});

// Mount routes
app.use('/api/auth', authRouts);
app.use('/api/users', usersRoutes);

app.use((req, res) => {
  res.status(404).json({ error: 'route not found' });
});
export default app;
