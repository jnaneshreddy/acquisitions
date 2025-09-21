import aj from '#config/arcjet.js';
import logger from '#config/logger.js';
import { slidingWindow } from '@arcjet/node';

const isDevelopment =
  process.env.ARCJET_ENV === 'development' ||
  process.env.NODE_ENV === 'development';

const securityMiddleware = async (req, res, next) => {
  try {
    const role = req.user?.role || 'guest';

    let limit;

    switch (role) {
      case 'admin':
        limit = 10; // Reduced for testing
        break;
      case 'user':
        limit = 5; // Reduced for testing
        break;
      case 'guest':
        limit = 3; // Reduced for testing
        break;
    }

    const client = aj.withRule(
      slidingWindow({
        mode: 'LIVE',
        interval: '30s', // Changed to 30 seconds for easier testing
        max: limit,
        name: `${role}-rate-limit`,
      })
    );

    const decision = await client.protect(req);

    // Log rate limiting decisions for debugging
    if (decision.isDenied()) {
      logger.warn('Request blocked by Arcjet', {
        reason: decision.reason,
        ip: req.ip,
        userAgent: req.get('User-Agent'),
        path: req.path,
        method: req.method,
      });
    }

    if (decision.isDenied() && decision.reason.isBot()) {
      logger.warn('Bot request blocked', {
        ip: req.ip,
        userAgent: req.get('User-Agent'),
        path: req.path,
      });

      return res.status(403).json({
        error: 'Forbidden',
        message: 'Automated requests are not allowed',
      });
    }

    if (decision.isDenied() && decision.reason.isShield()) {
      logger.warn('Shield Blocked request', {
        ip: req.ip,
        userAgent: req.get('User-Agent'),
        path: req.path,
        method: req.method,
      });

      return res.status(403).json({
        error: 'Forbidden',
        message: 'Request blocked by security policy',
      });
    }

    if (decision.isDenied() && decision.reason.isRateLimit()) {
      logger.warn('Rate limit exceeded', {
        ip: req.ip,
        userAgent: req.get('User-Agent'),
        path: req.path,
      });

      return res
        .status(403)
        .json({ error: 'Forbidden', message: 'Too many requests' });
    }

    next();
  } catch (e) {
    logger.error('Arcjet middleware error:', {
      error: e.message,
      stack: e.stack,
      isDevelopment,
    });

    // In development, log error but don't block requests
    if (isDevelopment) {
      logger.warn(
        'Arcjet error in development mode - allowing request to proceed'
      );
      return next();
    }

    // In production, return error response
    res.status(500).json({
      error: 'Internal server error',
      message: 'Something went wrong with security middleware',
    });
  }
};
export default securityMiddleware;
