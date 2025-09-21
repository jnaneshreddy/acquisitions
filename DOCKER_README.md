# 🚀 Acquisitions API - Docker Setup Guide

This guide ## 🔧 Development Setup (PostgreSQL Local)

The development environment uses **PostgreSQL 16** in a Docker container to provide a local database for development and testing.lains how to run the Acquisitions API using Docker with different configurations for development and production environments.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Development Setup (PostgreSQL Local)](#development-setup-postgresql-local)
- [Production Setup (Neon Cloud)](#production-setup-neon-cloud)
- [Environment Variables](#environment-variables)
- [Docker Commands](#docker-commands)
- [Troubleshooting](#troubleshooting)

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed:

- **Docker** (v20.10 or later)
- **Docker Compose** (v2.0 or later)
- **Git** (for cloning the repository)

## � Quick Start (Single Command)

For the fastest setup, use the quick start scripts:

### **Linux/macOS:**

```bash
# Development environment
./start.sh dev

# Production environment
./start.sh prod

# Other commands
./start.sh dev down      # Stop development
./start.sh prod logs     # View production logs
./start.sh dev restart   # Restart development
./start.sh dev clean     # Clean development (removes all data)
```

### **Windows:**

```cmd
:: Development environment
start.bat dev

:: Production environment
start.bat prod

:: Other commands
start.bat dev down       :: Stop development
start.bat prod logs      :: View production logs
start.bat dev restart    :: Restart development
start.bat dev clean      :: Clean development (removes all data)
```

---

## �🔧 Development Setup (Neon Local)

The development environment uses **Neon Local** to provide a local PostgreSQL database with Neon's branching capabilities.

### Quick Start

1. **Clone the repository**:

   ```bash
   git clone https://github.com/jnaneshreddy/acquisitions.git
   cd acquisitions
   ```

2. **Set up environment variables**:

   ```bash
   # Development environment file already exists
   # Check .env.development for development settings

   # For production, create from template:
   cp .env.production.template .env.production
   # Edit .env.production with your actual values
   ```

3. **Start the development environment**:

   ```bash
   docker-compose -f docker-compose.dev.yml up --build
   ```

4. **Access the application**:
   - API: http://localhost:3000
   - Health Check: http://localhost:3000/health
   - Database: localhost:5432 (user: `dev_user`, password: `dev_password`)

### Development Architecture

```mermaid
graph TD
    A[Developer] --> B[Docker Compose Dev]
    B --> C[App Container]
    B --> D[PostgreSQL Container]
    B --> E[Migration Container]
    C --> D
    E --> D
```

### Development Features

- **Hot Reload**: Source code changes are automatically reflected
- **PostgreSQL**: Full PostgreSQL database with standard SQL features
- **Debug Logging**: Detailed logs for development
- **Automatic Migrations**: Database setup runs automatically

### Stopping Development Environment

```bash
# Stop all services
docker-compose -f docker-compose.dev.yml down

# Stop and remove volumes (clears database)
docker-compose -f docker-compose.dev.yml down -v
```

## 🚀 Production Setup (Neon Cloud)

The production environment connects directly to **Neon Cloud** for a managed PostgreSQL database.

### Production Preparation

1. **Set up Neon Cloud Database**:
   - Go to [Neon Console](https://console.neon.tech/)
   - Create a new project
   - Copy the connection string

2. **Configure production environment**:

   ```bash
   cp .env.production.template .env.production
   # Edit .env.production with your actual values
   ```

3. **Update .env.production with your values**:
   ```bash
   DATABASE_URL=postgresql://username:password@your-endpoint.neon.tech/dbname?sslmode=require
   ARCJET_KEY=your_production_arcjet_key
   JWT_SECRET=your_super_secure_jwt_secret_256_bits_minimum
   ```

### Production Deployment

1. **Build and deploy**:

   ```bash
   # Ensure .env.production is configured
   # Start production environment
   docker-compose -f docker-compose.prod.yml up --build -d
   ```

2. **Access the application**:
   - API: http://localhost:3000 (or your domain)
   - Health Check: http://localhost:3000/health
   - Nginx Proxy: http://localhost:80

### Production Architecture

```mermaid
graph TD
    A[Users] --> B[Nginx Proxy]
    B --> C[App Container]
    C --> D[Neon Cloud Database]
    E[Migration Container] --> D
```

### Production Features

- **Optimized Image**: Multi-stage build for smaller image size
- **Security**: Non-root user, security headers via Nginx
- **Health Checks**: Automatic container health monitoring
- **Resource Limits**: CPU and memory constraints
- **SSL Ready**: Nginx configuration for HTTPS

## 🌍 Environment Variables

### Development (.env.development)

| Variable       | Value                                                               | Description                 |
| -------------- | ------------------------------------------------------------------- | --------------------------- |
| `NODE_ENV`     | `development`                                                       | Environment mode            |
| `DATABASE_URL` | `postgresql://dev_user:dev_password@postgres:5432/acquisitions_dev` | PostgreSQL Local connection |
| `ARCJET_ENV`   | `development`                                                       | Arcjet environment          |
| `LOG_LEVEL`    | `debug`                                                             | Logging level               |

### Production (.env.production)

| Variable       | Required | Description                   |
| -------------- | -------- | ----------------------------- |
| `NODE_ENV`     | ✅       | Set to `production`           |
| `DATABASE_URL` | ✅       | Neon Cloud connection string  |
| `ARCJET_KEY`   | ✅       | Production Arcjet API key     |
| `JWT_SECRET`   | ✅       | Strong JWT secret (256+ bits) |
| `LOG_LEVEL`    | ❌       | Defaults to `info`            |

## 🐳 Docker Commands

### Development Commands

```bash
# Start development environment
docker-compose -f docker-compose.dev.yml up

# Start in detached mode
docker-compose -f docker-compose.dev.yml up -d

# Rebuild containers
docker-compose -f docker-compose.dev.yml up --build

# View logs
docker-compose -f docker-compose.dev.yml logs -f app

# Run database migrations manually
docker-compose -f docker-compose.dev.yml run --rm migrate

# Access app container shell
docker-compose -f docker-compose.dev.yml exec app sh

# Access database
docker-compose -f docker-compose.dev.yml exec neon-local psql -U dev_user -d acquisitions_dev
```

### Production Commands

```bash
# Start production environment
docker-compose -f docker-compose.prod.yml up -d

# View production logs
docker-compose -f docker-compose.prod.yml logs -f

# Scale application (multiple instances)
docker-compose -f docker-compose.prod.yml up --scale app=3 -d

# Update application
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d

# Backup database (if using local volume)
docker-compose -f docker-compose.prod.yml exec app npm run db:backup
```

### General Commands

```bash
# Build specific target
docker build --target dev -t acquisitions-dev .
docker build --target production -t acquisitions-prod .

# Remove all containers and images
docker-compose -f docker-compose.dev.yml down --rmi all -v
docker-compose -f docker-compose.prod.yml down --rmi all -v

# Clean up Docker system
docker system prune -af
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Database Connection Failed

**Error**: `Error connecting to database`

**Solution**:

```bash
# Check if database container is running
docker-compose -f docker-compose.dev.yml ps

# Check database logs
docker-compose -f docker-compose.dev.yml logs neon-local

# Reset database
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.dev.yml up --build
```

#### 2. Port Already in Use

**Error**: `Port 3000 is already allocated`

**Solution**:

```bash
# Find process using port
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows

# Kill process or change port
docker-compose -f docker-compose.dev.yml down
```

#### 3. Arcjet Warnings in Development

**Error**: `Client IP address is missing`

**Solution**: This is expected in development. Arcjet will work properly in production with proper proxy configuration.

#### 4. Migration Failures

**Error**: `Migration failed`

**Solution**:

```bash
# Run migration manually
docker-compose -f docker-compose.dev.yml run --rm migrate

# Check database schema
docker-compose -f docker-compose.dev.yml exec neon-local psql -U dev_user -d acquisitions_dev -c "\dt"
```

### Health Checks

```bash
# Check application health
curl http://localhost:3000/health

# Check database connectivity
docker-compose -f docker-compose.dev.yml exec neon-local pg_isready -U dev_user
```

### Logs and Debugging

```bash
# View application logs
docker-compose -f docker-compose.dev.yml logs -f app

# View database logs
docker-compose -f docker-compose.dev.yml logs -f neon-local

# Debug container
docker-compose -f docker-compose.dev.yml exec app sh
```

## 📚 Additional Resources

- [PostgreSQL Docker Documentation](https://hub.docker.com/_/postgres)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Arcjet Documentation](https://docs.arcjet.com/)
- [Drizzle ORM Documentation](https://orm.drizzle.team/)

## 🤝 Contributing

1. Use the development environment for all development
2. Test changes in both development and production modes
3. Update this documentation for any infrastructure changes
4. Ensure all health checks pass before deployment

## 📞 Support

For issues related to:

- **Application**: Check application logs and health endpoints
- **Database**: Check PostgreSQL/Neon Cloud connectivity
- **Docker**: Verify Docker and Docker Compose versions
- **Arcjet**: Check API keys and rate limiting configuration

## 📋 Quick Reference

### **Single Command Execution:**

```bash
# Linux/macOS
./start.sh [dev|prod] [up|down|logs|restart|clean]

# Windows
start.bat [dev|prod] [up|down|logs|restart|clean]
```

### **Manual Docker Commands:**

```bash
# Development
docker-compose -f docker-compose.dev.yml up --build -d

# Production
docker-compose -f docker-compose.prod.yml up --build -d
```

### **Environment Files:**

- **`.env.development`** - Development configuration (PostgreSQL Local)
- **`.env.production`** - Production configuration (Neon Cloud)
- **`.env.production.template`** - Template for new deployments
