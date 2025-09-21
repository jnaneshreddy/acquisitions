import arcjet, { shield, detectBot, slidingWindow } from '@arcjet/node';

const aj = arcjet({
  key: process.env.ARCJET_KEY,
  // Use LIVE mode to actually test rate limiting
  rules: [
    shield({ mode: 'LIVE' }),
    detectBot({
      mode: 'LIVE',
      allow: ['CATEGORY:SEARCH_ENGINE', 'CATEGORY:PREVIEW'],
    }),
    slidingWindow({
      mode: 'LIVE',
      interval: '10s', // Changed to 10 seconds for easier testing
      max: 3, // Reduced to 3 requests per 10 seconds for easier testing
    }),
  ],
});

export default aj;
