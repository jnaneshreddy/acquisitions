#!/bin/bash

# Acquisitions API - Quick Start Script
# Usage: ./start.sh [dev|prod] [up|down|logs|restart]

set -e

# C    echo -e "${GREEN}✅ Production environment started${NC}"
    echo -e "${BLUE}🌐 Access your app at: http://localhost:8000${NC}"
    echo -e "${BLUE}🌐 Nginx proxy at: http://localhost:80${NC}"rs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_usage() {
    echo -e "${BLUE}🚀 Acquisitions API Quick Start${NC}"
    echo ""
    echo "Usage: $0 [ENVIRONMENT] [ACTION]"
    echo ""
    echo "ENVIRONMENTS:"
    echo "  dev     - Development environment (Neon Local)"
    echo "  prod    - Production environment (Neon Cloud)"
    echo ""
    echo "ACTIONS:"
    echo "  up      - Start services (default)"
    echo "  down    - Stop services"
    echo "  logs    - View logs"
    echo "  restart - Restart services"
    echo "  clean   - Clean and rebuild (dev only)"
    echo ""
    echo "Examples:"
    echo "  $0 dev           # Start development environment"
    echo "  $0 prod up       # Start production environment"
    echo "  $0 dev down      # Stop development environment"
    echo "  $0 prod logs     # View production logs"
    echo "  $0 dev restart   # Restart development environment"
    echo ""
}

check_requirements() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker is not installed or not in PATH${NC}"
        exit 1
    fi

    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker is not running${NC}"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}❌ Docker Compose is not installed${NC}"
        exit 1
    fi
}

check_env_file() {
    local env="$1"
    if [[ "$env" == "dev" ]]; then
        if [[ ! -f ".env.development" ]]; then
            echo -e "${RED}❌ .env.development file not found${NC}"
            echo -e "${YELLOW}💡 Please create .env.development with your development configuration${NC}"
            exit 1
        fi
    elif [[ "$env" == "prod" ]]; then
        if [[ ! -f ".env.production" ]]; then
            echo -e "${RED}❌ .env.production file not found${NC}"
            echo -e "${YELLOW}💡 Please copy .env.production.template to .env.production and configure it${NC}"
            exit 1
        fi
    fi
}

dev_up() {
    echo -e "${GREEN}🚀 Starting Development Environment...${NC}"
    check_env_file "dev"
    docker-compose -p acquisitions-dev -f docker-compose.dev.yml up --build -d
    echo -e "${GREEN}✅ Development environment started${NC}"
    echo -e "${BLUE}🌐 Access your app at: http://localhost:3001${NC}"
    echo -e "${BLUE}💚 Health check: http://localhost:3001/health${NC}"
}

dev_down() {
    echo -e "${YELLOW}🛑 Stopping Development Environment...${NC}"
    docker-compose -p acquisitions-dev -f docker-compose.dev.yml down
    echo -e "${GREEN}✅ Development environment stopped${NC}"
}

dev_logs() {
    echo -e "${BLUE}📋 Development Logs (Press Ctrl+C to exit)...${NC}"
    docker-compose -p acquisitions-dev -f docker-compose.dev.yml logs -f
}

dev_restart() {
    echo -e "${YELLOW}🔄 Restarting Development Environment...${NC}"
    docker-compose -p acquisitions-dev -f docker-compose.dev.yml down
    docker-compose -p acquisitions-dev -f docker-compose.dev.yml up --build -d
    echo -e "${GREEN}✅ Development environment restarted${NC}"
    echo -e "${BLUE}🌐 Access your app at: http://localhost:3001${NC}"
}

dev_clean() {
    echo -e "${RED}🧹 Cleaning Development Environment...${NC}"
    echo -e "${YELLOW}⚠️  This will remove all containers, volumes, and data!${NC}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker-compose -p acquisitions-dev -f docker-compose.dev.yml down -v --rmi all
        docker system prune -f
        echo -e "${GREEN}✅ Development environment cleaned${NC}"
    else
        echo -e "${BLUE}ℹ️  Cleanup cancelled${NC}"
    fi
}

prod_up() {
    echo -e "${GREEN}🚀 Starting Production Environment...${NC}"
    check_env_file "prod"
    docker-compose -p acquisitions-prod -f docker-compose.prod.yml up --build -d
    echo -e "${GREEN}✅ Production environment started${NC}"
    echo -e "${BLUE}🌐 Access your app at: http://localhost:8000${NC}"
    echo -e "${BLUE}🔒 Nginx proxy at: http://localhost:80${NC}"
}

prod_down() {
    echo -e "${YELLOW}🛑 Stopping Production Environment...${NC}"
    docker-compose -p acquisitions-prod -f docker-compose.prod.yml down
    echo -e "${GREEN}✅ Production environment stopped${NC}"
}

prod_logs() {
    echo -e "${BLUE}📋 Production Logs (Press Ctrl+C to exit)...${NC}"
    docker-compose -p acquisitions-prod -f docker-compose.prod.yml logs -f
}

prod_restart() {
    echo -e "${YELLOW}🔄 Restarting Production Environment...${NC}"
    docker-compose -p acquisitions-prod -f docker-compose.prod.yml down
    docker-compose -p acquisitions-prod -f docker-compose.prod.yml up --build -d
    echo -e "${GREEN}✅ Production environment restarted${NC}"
    echo -e "${BLUE}🌐 Access your app at: http://localhost:8000${NC}"
}

# Main script
main() {
    local env="${1:-}"
    local action="${2:-up}"

    # Show usage if no arguments or help requested
    if [[ -z "$env" ]] || [[ "$env" == "help" ]] || [[ "$env" == "--help" ]] || [[ "$env" == "-h" ]]; then
        print_usage
        exit 0
    fi

    # Validate environment
    if [[ "$env" != "dev" && "$env" != "prod" ]]; then
        echo -e "${RED}❌ Invalid environment: $env${NC}"
        echo -e "${YELLOW}💡 Use 'dev' or 'prod'${NC}"
        print_usage
        exit 1
    fi

    # Validate action
    if [[ "$env" == "dev" ]]; then
        case "$action" in
            "up"|"down"|"logs"|"restart"|"clean") ;;
            *) 
                echo -e "${RED}❌ Invalid action for dev: $action${NC}"
                echo -e "${YELLOW}💡 Available actions: up, down, logs, restart, clean${NC}"
                exit 1
                ;;
        esac
    else
        case "$action" in
            "up"|"down"|"logs"|"restart") ;;
            "clean")
                echo -e "${RED}❌ Clean action not available for production${NC}"
                exit 1
                ;;
            *)
                echo -e "${RED}❌ Invalid action for prod: $action${NC}"
                echo -e "${YELLOW}💡 Available actions: up, down, logs, restart${NC}"
                exit 1
                ;;
        esac
    fi

    # Check requirements
    check_requirements

    # Execute the command
    case "$env" in
        "dev")
            case "$action" in
                "up") dev_up ;;
                "down") dev_down ;;
                "logs") dev_logs ;;
                "restart") dev_restart ;;
                "clean") dev_clean ;;
            esac
            ;;
        "prod")
            case "$action" in
                "up") prod_up ;;
                "down") prod_down ;;
                "logs") prod_logs ;;
                "restart") prod_restart ;;
            esac
            ;;
    esac
}

# Run main function with all arguments
main "$@"