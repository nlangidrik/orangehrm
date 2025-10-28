#!/bin/bash

# OrangeHRM Production Installation Script
# For Debian/Ubuntu Servers
# Run with: bash <(curl -s https://raw.githubusercontent.com/nlangidrik/orangehrm/docker-setup/install-production.sh)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="/opt/orangehrm"
REPO_URL="https://github.com/nlangidrik/orangehrm.git"
BRANCH="docker-setup"

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

print_header() {
    echo ""
    echo "=================================================="
    echo "  OrangeHRM Production Server Installation"
    echo "=================================================="
    echo ""
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        log_info "Run as a regular user with sudo privileges"
        exit 1
    fi
    
    if ! sudo -n true 2>/dev/null; then
        log_error "This script requires sudo privileges"
        exit 1
    fi
}

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
        log_info "Detected OS: $PRETTY_NAME"
    else
        log_error "Cannot detect operating system"
        exit 1
    fi
    
    if [[ "$OS" != "debian" && "$OS" != "ubuntu" ]]; then
        log_warning "This script is designed for Debian/Ubuntu"
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

update_system() {
    log_info "Updating system packages..."
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y curl wget git apt-transport-https ca-certificates gnupg lsb-release openssl
    log_success "System updated"
}

install_docker() {
    if command -v docker &> /dev/null; then
        log_info "Docker is already installed: $(docker --version)"
        return
    fi
    
    log_info "Installing Docker..."
    
    # Remove old versions
    sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Add Docker's official GPG key
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/$OS/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Set up repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    
    log_success "Docker installed successfully"
}

install_docker_compose() {
    if docker compose version &> /dev/null; then
        log_info "Docker Compose is already installed: $(docker compose version)"
        return
    fi
    
    log_info "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    log_success "Docker Compose installed successfully"
}

clone_repository() {
    log_info "Cloning OrangeHRM repository..."
    
    if [ -d "$INSTALL_DIR" ]; then
        log_warning "Directory $INSTALL_DIR already exists"
        read -p "Remove and clone fresh? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo rm -rf $INSTALL_DIR
        else
            log_info "Using existing directory"
            return
        fi
    fi
    
    sudo git clone -b $BRANCH $REPO_URL $INSTALL_DIR
    sudo chown -R $USER:$USER $INSTALL_DIR
    log_success "Repository cloned"
}

configure_environment() {
    log_info "Configuring environment..."
    
    cd $INSTALL_DIR
    
    if [ ! -f .env ]; then
        cp env.example .env
        
        # Generate random passwords
        MYSQL_ROOT_PASS=$(openssl rand -base64 24)
        MYSQL_PASS=$(openssl rand -base64 16)
        ENCRYPTION_KEY=$(openssl rand -base64 32)
        
        # Update .env file
        sed -i "s/MYSQL_ROOT_PASSWORD=.*/MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASS/" .env
        sed -i "s/MYSQL_PASSWORD=.*/MYSQL_PASSWORD=$MYSQL_PASS/" .env
        sed -i "s/OHRM_DB_PASSWORD=.*/OHRM_DB_PASSWORD=$MYSQL_PASS/" .env
        sed -i "s/OHRM_ENCRYPTION_KEY=.*/OHRM_ENCRYPTION_KEY=$ENCRYPTION_KEY/" .env
        
        log_success "Environment configured with secure passwords"
        log_warning "Important: Save these credentials!"
        echo ""
        echo "MySQL Root Password: $MYSQL_ROOT_PASS"
        echo "MySQL User Password: $MYSQL_PASS"
        echo ""
        read -p "Press Enter to continue..."
    else
        log_info ".env file already exists, skipping"
    fi
}

setup_firewall() {
    log_info "Configuring firewall..."
    
    if ! command -v ufw &> /dev/null; then
        sudo apt install -y ufw
    fi
    
    # Configure UFW
    sudo ufw --force enable
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    
    log_success "Firewall configured"
}

create_ssl_certificate() {
    log_info "Creating SSL certificate..."
    
    cd $INSTALL_DIR
    mkdir -p ssl
    
    read -p "Enter your domain name (or press Enter to use self-signed for IP): " DOMAIN
    
    if [ -z "$DOMAIN" ]; then
        DOMAIN="localhost"
    fi
    
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ssl/key.pem \
        -out ssl/cert.pem \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=$DOMAIN"
    
    log_success "SSL certificate created"
}

deploy_application() {
    log_info "Deploying OrangeHRM application..."
    
    cd $INSTALL_DIR
    
    # Use newgrp to apply docker group in same script
    sg docker -c "docker compose -f docker-compose.yml up -d --build"
    
    log_success "Application deployed"
}

wait_for_services() {
    log_info "Waiting for services to start..."
    
    cd $INSTALL_DIR
    
    # Wait for MySQL
    local timeout=60
    while ! sg docker -c "docker compose exec -T mysql mysqladmin ping -h localhost --silent" 2>/dev/null; do
        echo -n "."
        sleep 2
        timeout=$((timeout - 2))
        if [ $timeout -le 0 ]; then
            log_error "MySQL failed to start"
            return 1
        fi
    done
    echo ""
    log_success "MySQL is ready"
    
    # Wait for application
    timeout=120
    while ! curl -f http://localhost:8080/ > /dev/null 2>&1; do
        echo -n "."
        sleep 5
        timeout=$((timeout - 5))
        if [ $timeout -le 0 ]; then
            log_error "Application failed to start"
            return 1
        fi
    done
    echo ""
    log_success "Application is ready"
}

create_systemd_service() {
    log_info "Creating systemd service..."
    
    sudo tee /etc/systemd/system/orangehrm.service > /dev/null <<EOF
[Unit]
Description=OrangeHRM Docker Compose
Requires=docker.service
After=docker.service network.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
User=$USER
Group=$USER

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable orangehrm.service
    
    log_success "Systemd service created and enabled"
}

print_summary() {
    local SERVER_IP=$(hostname -I | awk '{print $1}')
    
    echo ""
    echo "=================================================="
    echo "  Installation Complete!"
    echo "=================================================="
    echo ""
    echo "🎉 OrangeHRM has been successfully installed!"
    echo ""
    echo "Access Information:"
    echo "==================="
    echo "Application URL: http://$SERVER_IP:8080"
    echo "Installation Directory: $INSTALL_DIR"
    echo ""
    echo "Next Steps:"
    echo "==========="
    echo "1. Open your browser and navigate to: http://$SERVER_IP:8080"
    echo "2. Follow the OrangeHRM installation wizard"
    echo "3. Use these database credentials:"
    echo "   - Host: mysql"
    echo "   - Port: 3306"
    echo "   - Database: orangehrm_mysql"
    echo "   - Username: orangehrm"
    echo "   - Password: (check your .env file)"
    echo ""
    echo "Useful Commands:"
    echo "==============="
    echo "View status: cd $INSTALL_DIR && docker compose ps"
    echo "View logs: cd $INSTALL_DIR && docker compose logs -f"
    echo "Stop: cd $INSTALL_DIR && docker compose down"
    echo "Start: cd $INSTALL_DIR && docker compose up -d"
    echo "Restart: sudo systemctl restart orangehrm"
    echo ""
    echo "Documentation:"
    echo "=============="
    echo "Quick Start: $INSTALL_DIR/QUICK_START.md"
    echo "Production Guide: $INSTALL_DIR/PRODUCTION_SETUP.md"
    echo "Deployment Guide: $INSTALL_DIR/DEPLOYMENT.md"
    echo ""
    echo "⚠️  IMPORTANT: Your database credentials are in: $INSTALL_DIR/.env"
    echo "    Please save them securely!"
    echo ""
}

# Main installation flow
main() {
    print_header
    
    log_info "Starting OrangeHRM installation..."
    echo ""
    
    check_root
    detect_os
    update_system
    install_docker
    install_docker_compose
    clone_repository
    configure_environment
    setup_firewall
    create_ssl_certificate
    deploy_application
    wait_for_services
    create_systemd_service
    print_summary
    
    log_success "Installation completed successfully!"
}

# Run main function
main "$@"
