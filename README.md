# Acquisitions API

A Node.js backend service built with Express, PostgreSQL, and JWT authentication.

## Features

- 🚀 **Express.js** - Fast, unopinionated web framework
- 🗃️ **PostgreSQL** - Reliable relational database
- 🔐 **JWT Authentication** - Secure token-based auth
- 🛡️ **Arcjet Security** - Rate limiting and bot protection
- 🐳 **Docker Support** - Containerized deployment
- 🧪 **Testing** - Jest with coverage reports
- 📝 **Code Quality** - ESLint and Prettier
- 🔄 **CI/CD** - GitHub Actions workflows

## Quick Start

### Development

```bash
# Start development environment
./start.bat dev        # Windows
./start.sh dev          # Linux/macOS

# Access the API
curl http://localhost:3001/health
```

### Production

```bash
# Start production environment
./start.bat prod        # Windows
./start.sh prod         # Linux/macOS

# Access via Nginx proxy
curl http://localhost/health
```

### Docker

```bash
# Pull and run the latest image
docker pull jnaneshreddy/acquisitions:latest
docker run -p 3000:3000 jnaneshreddy/acquisitions:latest
```

## API Endpoints

- `GET /health` - Health check
- `GET /api` - API status
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/users/profile` - Get user profile (authenticated)

## Environment Variables

```bash
# Server Configuration
PORT=3000
NODE_ENV=development
LOG_LEVEL=info

# Database
DATABASE_URL=postgresql://user:password@host:port/database

# Authentication
JWT_SECRET=your-secret-key
ARCJET_KEY=your-arcjet-key
```

## Development

```bash
# Install dependencies
npm install

# Run tests
npm test

# Lint and format
npm run lint
npm run format

# Database setup
npm run db:setup
```

## License

ISC