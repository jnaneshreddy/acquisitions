#!/bin/bash

# Acquisitions API Docker Management Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Development environment functions
dev_start() {
    print_header "🚀 Starting Development Environment..."
    check_docker
    
    if [ ! -f ".env.development" ]; then
        print_error ".env.development file not found!"
        print_status "Please create .env.development with your development configuration"
        exit 1
    fi
    
    docker-compose -f docker-compose.dev.yml up --build
}

dev_start_detached() {
    print_header "🚀 Starting Development Environment (Detached)..."
    check_docker
    
    if [ ! -f ".env.development" ]; then
        print_error ".env.development file not found!"
        print_status "Please create .env.development with your development configuration"
        exit 1
    fi
    
    docker-compose -f docker-compose.dev.yml up --build -d
    print_status "Development environment started in background"
    print_status "Access your app at: http://localhost:3000"
    print_status "View logs with: ./docker-manage.sh dev-logs"
}

dev_stop() {
    print_header "🛑 Stopping Development Environment..."
    docker-compose -f docker-compose.dev.yml down
    print_status "Development environment stopped"
}

dev_restart() {
    print_header "🔄 Restarting Development Environment..."
    dev_stop
    dev_start_detached
}

dev_logs() {
    print_header "📋 Development Logs..."
    docker-compose -f docker-compose.dev.yml logs -f
}

dev_shell() {
    print_header "💻 Opening App Container Shell..."
    docker-compose -f docker-compose.dev.yml exec app sh
}

dev_db_shell() {
    print_header "🗄️ Opening Database Shell..."
    docker-compose -f docker-compose.dev.yml exec neon-local psql -U dev_user -d acquisitions_dev
}

dev_clean() {
    print_header "🧹 Cleaning Development Environment..."
    print_warning "This will remove all containers, volumes, and data!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose -f docker-compose.dev.yml down -v --rmi all
        docker system prune -f
        print_status "Development environment cleaned"
    else
        print_status "Cleanup cancelled"
    fi
}

# Production environment functions
prod_start() {
    print_header "🚀 Starting Production Environment..."
    check_docker
    
    if [ ! -f ".env.production" ]; then
        print_error ".env.production file not found!"
        print_status "Please copy .env.production.template to .env.production and configure it"
        exit 1
    fi
    
    docker-compose -f docker-compose.prod.yml up --build -d
    print_status "Production environment started"
    print_status "Access your app at: http://localhost:3000"
}

prod_stop() {
    print_header "🛑 Stopping Production Environment..."
    docker-compose -f docker-compose.prod.yml down
    print_status "Production environment stopped"
}

prod_logs() {
    print_header "📋 Production Logs..."
    docker-compose -f docker-compose.prod.yml logs -f
}

prod_update() {
    print_header "🔄 Updating Production Environment..."
    docker-compose -f docker-compose.prod.yml pull
    docker-compose -f docker-compose.prod.yml up -d
    print_status "Production environment updated"
}

# Utility functions
health_check() {
    print_header "🏥 Health Check..."
    
    if curl -f http://localhost:3000/health > /dev/null 2>&1; then
        print_status "✅ Application is healthy"
        curl -s http://localhost:3000/health | jq .
    else
        print_error "❌ Application health check failed"
        exit 1
    fi
}

show_status() {
    print_header "📊 Environment Status..."
    
    echo "Development Services:"
    docker-compose -f docker-compose.dev.yml ps
    
    echo
    echo "Production Services:"
    docker-compose -f docker-compose.prod.yml ps
}

# Help function
show_help() {
    print_header "🐳 Acquisitions API Docker Management"
    echo
    echo "Development Commands:"
    echo "  dev-start       Start development environment"
    echo "  dev-start-bg    Start development environment in background"
    echo "  dev-stop        Stop development environment"
    echo "  dev-restart     Restart development environment"
    echo "  dev-logs        View development logs"
    echo "  dev-shell       Open app container shell"
    echo "  dev-db          Open database shell"
    echo "  dev-clean       Clean development environment (removes all data)"
    echo
    echo "Production Commands:"
    echo "  prod-start      Start production environment"
    echo "  prod-stop       Stop production environment"
    echo "  prod-logs       View production logs"
    echo "  prod-update     Update production environment"
    echo
    echo "Utility Commands:"
    echo "  health          Check application health"
    echo "  status          Show environment status"
    echo "  help            Show this help message"
    echo
    echo "Examples:"
    echo "  ./docker-manage.sh dev-start"
    echo "  ./docker-manage.sh prod-start"
    echo "  ./docker-manage.sh health"
}

# Main script logic
case "${1:-help}" in
    "dev-start")
        dev_start
        ;;
    "dev-start-bg")
        dev_start_detached
        ;;
    "dev-stop")
        dev_stop
        ;;
    "dev-restart")
        dev_restart
        ;;
    "dev-logs")
        dev_logs
        ;;
    "dev-shell")
        dev_shell
        ;;
    "dev-db")
        dev_db_shell
        ;;
    "dev-clean")
        dev_clean
        ;;
    "prod-start")
        prod_start
        ;;
    "prod-stop")
        prod_stop
        ;;
    "prod-logs")
        prod_logs
        ;;
    "prod-update")
        prod_update
        ;;
    "health")
        health_check
        ;;
    "status")
        show_status
        ;;
    "help"|*)
        show_help
        ;;
esac