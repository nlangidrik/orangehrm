#!/bin/bash

# OrangeHRM Deployment Script for Debian Server
# This script sets up OrangeHRM on a Debian server using Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="orangehrm"
DOCKER_COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"

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

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        log_info "Run: curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
        exit 1
    fi
    log_success "Docker is installed"
}

# Check if Docker Compose is installed
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed. Please install Docker Compose first."
        log_info "Run: sudo curl -L \"https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose"
        exit 1
    fi
    log_success "Docker Compose is installed"
}

# Install required packages
install_packages() {
    log_info "Installing required packages..."
    sudo apt-get update
    sudo apt-get install -y curl wget git unzip
    log_success "Required packages installed"
}

# Create environment file
create_env_file() {
    if [ ! -f "$ENV_FILE" ]; then
        log_info "Creating environment file..."
        cp env.example "$ENV_FILE"
        log_warning "Please edit $ENV_FILE with your configuration before continuing"
        log_info "Generated random passwords:"
        echo "MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)"
        echo "MYSQL_PASSWORD=$(openssl rand -base64 16)"
        echo "OHRM_ENCRYPTION_KEY=$(openssl rand -base64 32)"
        echo ""
        read -p "Press Enter to continue after editing the .env file..."
    else
        log_success "Environment file already exists"
    fi
}

# Create SSL certificates (self-signed for development)
create_ssl_certificates() {
    if [ ! -d "ssl" ]; then
        log_info "Creating SSL certificates..."
        mkdir -p ssl
        
        # Generate self-signed certificate
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout ssl/key.pem \
            -out ssl/cert.pem \
            -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
        
        log_success "SSL certificates created"
        log_warning "For production, replace these with real SSL certificates"
    else
        log_success "SSL certificates already exist"
    fi
}

# Set up firewall
setup_firewall() {
    log_info "Setting up firewall..."
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw --force enable
    log_success "Firewall configured"
}

# Create systemd service
create_systemd_service() {
    log_info "Creating systemd service..."
    
    sudo tee /etc/systemd/system/orangehrm.service > /dev/null <<EOF
[Unit]
Description=OrangeHRM Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$(pwd)
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable orangehrm.service
    log_success "Systemd service created and enabled"
}

# Deploy application
deploy_application() {
    log_info "Deploying OrangeHRM application..."
    
    # Pull latest images
    docker-compose pull
    
    # Build application
    docker-compose build --no-cache
    
    # Start services
    docker-compose up -d
    
    log_success "Application deployed successfully"
}

# Wait for services to be ready
wait_for_services() {
    log_info "Waiting for services to be ready..."
    
    # Wait for database
    log_info "Waiting for database..."
    timeout=60
    while ! docker-compose exec -T mysql mysqladmin ping -h localhost --silent; do
        sleep 2
        timeout=$((timeout - 2))
        if [ $timeout -le 0 ]; then
            log_error "Database failed to start"
            exit 1
        fi
    done
    log_success "Database is ready"
    
    # Wait for application
    log_info "Waiting for application..."
    timeout=120
    while ! curl -f http://localhost:8080/ > /dev/null 2>&1; do
        sleep 5
        timeout=$((timeout - 5))
        if [ $timeout -le 0 ]; then
            log_error "Application failed to start"
            exit 1
        fi
    done
    log_success "Application is ready"
}

# Show deployment information
show_deployment_info() {
    log_success "OrangeHRM deployment completed successfully!"
    echo ""
    echo "Access Information:"
    echo "=================="
    echo "Application URL: http://$(hostname -I | awk '{print $1}'):8080"
    echo "Admin Panel: http://$(hostname -I | awk '{print $1}'):8080"
    echo ""
    echo "Default Admin Credentials:"
    echo "Username: Admin"
    echo "Password: Ohrm@1423"
    echo ""
    echo "Database Information:"
    echo "Host: localhost"
    echo "Port: 3306"
    echo "Database: orangehrm_mysql"
    echo "Username: orangehrm"
    echo "Password: (check your .env file)"
    echo ""
    echo "Useful Commands:"
    echo "==============="
    echo "View logs: docker-compose logs -f"
    echo "Stop services: docker-compose down"
    echo "Start services: docker-compose up -d"
    echo "Restart services: docker-compose restart"
    echo "Update application: git pull && docker-compose up -d --build"
    echo ""
    echo "Service Management:"
    echo "=================="
    echo "Start service: sudo systemctl start orangehrm"
    echo "Stop service: sudo systemctl stop orangehrm"
    echo "Status: sudo systemctl status orangehrm"
}

# Main deployment function
main() {
    log_info "Starting OrangeHRM deployment on Debian server..."
    
    check_root
    check_docker
    check_docker_compose
    install_packages
    create_env_file
    create_ssl_certificates
    setup_firewall
    create_systemd_service
    deploy_application
    wait_for_services
    show_deployment_info
}

# Run main function
main "$@"
