@echo off
REM Acquisitions API - Quick Start Script for Windows
REM Usage: start.bat [dev|prod] [up|down|logs|restart]

setlocal enabledelayedexpansion

set "env=%~1"
set "action=%~2"

REM Default action is 'up'
if "%action%"=="" set "action=up"

REM Show usage if no arguments
if "%env%"=="" goto :show_usage
if "%env%"=="help" goto :show_usage
if "%env%"=="--help" goto :show_usage
if "%env%"=="-h" goto :show_usage

REM Validate environment
if not "%env%"=="dev" if not "%env%"=="prod" (
    echo [ERROR] Invalid environment: %env%
    echo [INFO] Use 'dev' or 'prod'
    goto :show_usage
)

REM Check Docker
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running. Please start Docker and try again.
    exit /b 1
)

REM Execute commands
if "%env%"=="dev" (
    if "%action%"=="up" goto :dev_up
    if "%action%"=="down" goto :dev_down
    if "%action%"=="logs" goto :dev_logs
    if "%action%"=="restart" goto :dev_restart
    if "%action%"=="clean" goto :dev_clean
    goto :invalid_action
)

if "%env%"=="prod" (
    if "%action%"=="up" goto :prod_up
    if "%action%"=="down" goto :prod_down
    if "%action%"=="logs" goto :prod_logs
    if "%action%"=="restart" goto :prod_restart
    if "%action%"=="clean" (
        echo [ERROR] Clean action not available for production
        exit /b 1
    )
    goto :invalid_action
)

:dev_up
echo [INFO] Starting Development Environment...
if not exist ".env.development" (
    echo [ERROR] .env.development file not found
    echo [INFO] Please create .env.development with your development configuration
    exit /b 1
)
docker-compose -p acquisitions-dev -f docker-compose.dev.yml up --build -d
echo [SUCCESS] Development environment started
echo [INFO] Access your app at: http://localhost:3001
echo [INFO] Health check: http://localhost:3001/health
goto :end

:dev_down
echo [INFO] Stopping Development Environment...
docker-compose -p acquisitions-dev -f docker-compose.dev.yml down
echo [SUCCESS] Development environment stopped
goto :end

:dev_logs
echo [INFO] Development Logs (Press Ctrl+C to exit)...
docker-compose -p acquisitions-dev -f docker-compose.dev.yml logs -f
goto :end

:dev_restart
echo [INFO] Restarting Development Environment...
docker-compose -p acquisitions-dev -f docker-compose.dev.yml down
docker-compose -p acquisitions-dev -f docker-compose.dev.yml up --build -d
echo [SUCCESS] Development environment restarted
echo [INFO] Access your app at: http://localhost:3001
goto :end

:dev_clean
echo [WARNING] This will remove all containers, volumes, and data!
set /p "confirm=Are you sure? (y/N): "
if /i "%confirm%"=="y" (
    docker-compose -p acquisitions-dev -f docker-compose.dev.yml down -v --rmi all
    docker system prune -f
    echo [SUCCESS] Development environment cleaned
) else (
    echo [INFO] Cleanup cancelled
)
goto :end

:prod_up
echo [INFO] Starting Production Environment...
if not exist ".env.production" (
    echo [ERROR] .env.production file not found
    echo [INFO] Please copy .env.production.template to .env.production and configure it
    exit /b 1
)
docker-compose -p acquisitions-prod -f docker-compose.prod.yml up --build -d
echo [SUCCESS] Production environment started
echo [INFO] Access your app at: http://localhost:8000
echo [INFO] Nginx proxy at: http://localhost:80
goto :end

:prod_down
echo [INFO] Stopping Production Environment...
docker-compose -p acquisitions-prod -f docker-compose.prod.yml down
echo [SUCCESS] Production environment stopped
goto :end

:prod_logs
echo [INFO] Production Logs (Press Ctrl+C to exit)...
docker-compose -p acquisitions-prod -f docker-compose.prod.yml logs -f
goto :end

:prod_restart
echo [INFO] Restarting Production Environment...
docker-compose -p acquisitions-prod -f docker-compose.prod.yml down
docker-compose -p acquisitions-prod -f docker-compose.prod.yml up --build -d
echo [SUCCESS] Production environment restarted
echo [INFO] Access your app at: http://localhost:8000
goto :end

:invalid_action
echo [ERROR] Invalid action: %action%
if "%env%"=="dev" (
    echo [INFO] Available actions for dev: up, down, logs, restart, clean
) else (
    echo [INFO] Available actions for prod: up, down, logs, restart
)
exit /b 1

:show_usage
echo.
echo Acquisitions API Quick Start
echo.
echo Usage: %~nx0 [ENVIRONMENT] [ACTION]
echo.
echo ENVIRONMENTS:
echo   dev     - Development environment (Neon Local)
echo   prod    - Production environment (Neon Cloud)
echo.
echo ACTIONS:
echo   up      - Start services (default)
echo   down    - Stop services
echo   logs    - View logs
echo   restart - Restart services
echo   clean   - Clean and rebuild (dev only)
echo.
echo Examples:
echo   %~nx0 dev           # Start development environment
echo   %~nx0 prod up       # Start production environment
echo   %~nx0 dev down      # Stop development environment
echo   %~nx0 prod logs     # View production logs
echo   %~nx0 dev restart   # Restart development environment
echo.
goto :end

:end
endlocal