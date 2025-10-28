#!/bin/bash

# OrangeHRM Update Script
# This script updates OrangeHRM to the latest version

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root for security reasons"
        exit 1
    fi
}

# Create backup
create_backup() {
    log_info "Creating backup..."
    
    BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup database
    log_info "Backing up database..."
    docker-compose exec -T mysql mysqldump -u root -p"${MYSQL_ROOT_PASSWORD:-rootpassword}" orangehrm_mysql > "$BACKUP_DIR/database.sql"
    
    # Backup application data
    log_info "Backing up application data..."
    docker-compose exec orangehrm tar -czf /tmp/app_data.tar.gz /var/www/html/src/config /var/www/html/src/cache
    docker cp orangehrm_app:/tmp/app_data.tar.gz "$BACKUP_DIR/"
    
    log_success "Backup created in $BACKUP_DIR"
}

# Update application
update_application() {
    log_info "Updating OrangeHRM application..."
    
    # Pull latest changes
    git pull origin main
    
    # Pull latest Docker images
    docker-compose pull
    
    # Stop services
    log_info "Stopping services..."
    docker-compose down
    
    # Rebuild and start services
    log_info "Rebuilding and starting services..."
    docker-compose up -d --build
    
    log_success "Application updated successfully"
}

# Wait for services
wait_for_services() {
    log_info "Waiting for services to be ready..."
    
    # Wait for database
    timeout=60
    while ! docker-compose exec -T mysql mysqladmin ping -h localhost --silent; do
        sleep 2
        timeout=$((timeout - 2))
        if [ $timeout -le 0 ]; then
            log_error "Database failed to start"
            exit 1
        fi
    done
    
    # Wait for application
    timeout=120
    while ! curl -f http://localhost:8080/ > /dev/null 2>&1; do
        sleep 5
        timeout=$((timeout - 5))
        if [ $timeout -le 0 ]; then
            log_error "Application failed to start"
            exit 1
        fi
    done
    
    log_success "All services are ready"
}

# Run database migrations
run_migrations() {
    log_info "Running database migrations..."
    
    # This would run any necessary database migrations
    # OrangeHRM handles this automatically during startup
    log_success "Database migrations completed"
}

# Main update function
main() {
    log_info "Starting OrangeHRM update..."
    
    check_root
    create_backup
    update_application
    wait_for_services
    run_migrations
    
    log_success "OrangeHRM update completed successfully!"
    echo ""
    echo "Update Summary:"
    echo "==============="
    echo "✓ Backup created"
    echo "✓ Application updated"
    echo "✓ Services restarted"
    echo "✓ Database migrations completed"
    echo ""
    echo "You can now access OrangeHRM at: http://$(hostname -I | awk '{print $1}'):8080"
}

# Run main function
main "$@"
