@echo off
REM Acquisitions API Docker Management Script for Windows

setlocal enabledelayedexpansion

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running. Please start Docker and try again.
    exit /b 1
)

set "command=%~1"
if "%command%"=="" set "command=help"

if "%command%"=="dev-start" (
    echo [INFO] Starting Development Environment...
    if not exist ".env.development" (
        echo [ERROR] .env.development file not found!
        echo [INFO] Please create .env.development with your development configuration
        exit /b 1
    )
    docker-compose -f docker-compose.dev.yml up --build
) else if "%command%"=="dev-start-bg" (
    echo [INFO] Starting Development Environment (Detached)...
    if not exist ".env.development" (
        echo [ERROR] .env.development file not found!
        echo [INFO] Please create .env.development with your development configuration
        exit /b 1
    )
    docker-compose -f docker-compose.dev.yml up --build -d
    echo [INFO] Development environment started in background
    echo [INFO] Access your app at: http://localhost:3000
) else if "%command%"=="dev-stop" (
    echo [INFO] Stopping Development Environment...
    docker-compose -f docker-compose.dev.yml down
    echo [INFO] Development environment stopped
) else if "%command%"=="dev-restart" (
    echo [INFO] Restarting Development Environment...
    docker-compose -f docker-compose.dev.yml down
    docker-compose -f docker-compose.dev.yml up --build -d
    echo [INFO] Development environment restarted
) else if "%command%"=="dev-logs" (
    echo [INFO] Development Logs...
    docker-compose -f docker-compose.dev.yml logs -f
) else if "%command%"=="dev-shell" (
    echo [INFO] Opening App Container Shell...
    docker-compose -f docker-compose.dev.yml exec app sh
) else if "%command%"=="dev-db" (
    echo [INFO] Opening Database Shell...
    docker-compose -f docker-compose.dev.yml exec neon-local psql -U dev_user -d acquisitions_dev
) else if "%command%"=="prod-start" (
    echo [INFO] Starting Production Environment...
    if not exist ".env.production" (
        echo [ERROR] .env.production file not found!
        echo [INFO] Please copy .env.production.template to .env.production and configure it
        exit /b 1
    )
    docker-compose -f docker-compose.prod.yml up --build -d
    echo [INFO] Production environment started
) else if "%command%"=="prod-stop" (
    echo [INFO] Stopping Production Environment...
    docker-compose -f docker-compose.prod.yml down
    echo [INFO] Production environment stopped
) else if "%command%"=="prod-logs" (
    echo [INFO] Production Logs...
    docker-compose -f docker-compose.prod.yml logs -f
) else if "%command%"=="health" (
    echo [INFO] Health Check...
    curl -f http://localhost:3000/health
    if errorlevel 1 (
        echo [ERROR] Application health check failed
        exit /b 1
    ) else (
        echo [INFO] Application is healthy
    )
) else if "%command%"=="status" (
    echo [INFO] Environment Status...
    echo Development Services:
    docker-compose -f docker-compose.dev.yml ps
    echo.
    echo Production Services:
    docker-compose -f docker-compose.prod.yml ps
) else (
    echo Acquisitions API Docker Management
    echo.
    echo Development Commands:
    echo   dev-start       Start development environment
    echo   dev-start-bg    Start development environment in background
    echo   dev-stop        Stop development environment
    echo   dev-restart     Restart development environment
    echo   dev-logs        View development logs
    echo   dev-shell       Open app container shell
    echo   dev-db          Open database shell
    echo.
    echo Production Commands:
    echo   prod-start      Start production environment
    echo   prod-stop       Stop production environment
    echo   prod-logs       View production logs
    echo.
    echo Utility Commands:
    echo   health          Check application health
    echo   status          Show environment status
    echo   help            Show this help message
    echo.
    echo Examples:
    echo   docker-manage.bat dev-start
    echo   docker-manage.bat prod-start
    echo   docker-manage.bat health
)

endlocal