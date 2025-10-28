# OrangeHRM Docker Deployment Guide

This guide will help you deploy OrangeHRM on a Debian server using Docker and Docker Compose.

## Prerequisites

### Server Requirements
- Debian 10/11/12 (or Ubuntu 20.04+)
- Minimum 2GB RAM (4GB+ recommended)
- Minimum 20GB disk space
- Root or sudo access

### Software Requirements
- Docker Engine 20.10+
- Docker Compose 2.0+
- Git
- OpenSSL (for SSL certificates)

## Quick Start

### 1. Clone the Repository
```bash
git clone <your-repository-url>
cd orangehrm-1
```

### 2. Run the Deployment Script
```bash
chmod +x deploy.sh
./deploy.sh
```

The script will:
- Check system requirements
- Install necessary packages
- Create environment configuration
- Set up SSL certificates
- Configure firewall
- Deploy the application
- Create systemd service for auto-start

## Manual Setup

If you prefer to set up manually, follow these steps:

### 1. Install Docker and Docker Compose

```bash
# Update system
sudo apt-get update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout and login again to apply group changes
```

### 2. Configure Environment

```bash
# Copy environment template
cp env.example .env

# Edit configuration
nano .env
```

Update the following variables in `.env`:
- `MYSQL_ROOT_PASSWORD`: Strong password for MySQL root
- `MYSQL_PASSWORD`: Strong password for OrangeHRM database user
- `OHRM_ENCRYPTION_KEY`: 32-character encryption key
- `OHRM_APP_URL`: Your domain name or server IP

### 3. Create SSL Certificates

For development/testing:
```bash
mkdir ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/key.pem \
    -out ssl/cert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=your-domain.com"
```

For production, use Let's Encrypt or purchase SSL certificates.

### 4. Deploy the Application

```bash
# Build and start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### 5. Configure Firewall

```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MYSQL_ROOT_PASSWORD` | MySQL root password | `rootpassword` |
| `MYSQL_DATABASE` | Database name | `orangehrm_mysql` |
| `MYSQL_USER` | Database user | `orangehrm` |
| `MYSQL_PASSWORD` | Database password | `orangehrm123` |
| `OHRM_APP_URL` | Application URL | `http://your-domain.com` |
| `OHRM_ADMIN_USERNAME` | Admin username | `Admin` |
| `OHRM_ADMIN_PASSWORD` | Admin password | `Ohrm@1423` |

### Nginx Configuration

The nginx configuration is located in `nginx/conf.d/orangehrm.conf`. Key features:
- HTTP to HTTPS redirect
- SSL/TLS termination
- Rate limiting
- Security headers
- Static file caching
- Reverse proxy to OrangeHRM

### Database Configuration

MySQL 8.0 is used with the following settings:
- Character set: `utf8mb4`
- Collation: `utf8mb4_unicode_ci`
- SQL mode: Strict mode enabled

## Accessing the Application

### Initial Setup
1. Open your browser and navigate to `http://your-server-ip:8080`
2. You'll be redirected to the OrangeHRM installer
3. Follow the installation wizard
4. Use the admin credentials from your `.env` file

### Default Credentials
- **Username**: Admin
- **Password**: Ohrm@1423

**Important**: Change these credentials immediately after first login!

## Service Management

### Using Docker Compose
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Restart services
docker-compose restart

# View logs
docker-compose logs -f

# Update application
git pull
docker-compose up -d --build
```

### Using Systemd (Auto-start)
```bash
# Start service
sudo systemctl start orangehrm

# Stop service
sudo systemctl stop orangehrm

# Enable auto-start
sudo systemctl enable orangehrm

# Check status
sudo systemctl status orangehrm
```

## Monitoring and Maintenance

### Health Checks
```bash
# Check application health
curl http://localhost:8080/health

# Check database
docker-compose exec mysql mysqladmin ping

# Check all services
docker-compose ps
```

### Logs
```bash
# Application logs
docker-compose logs orangehrm

# Database logs
docker-compose logs mysql

# Nginx logs
docker-compose logs nginx

# All logs
docker-compose logs -f
```

### Backup
```bash
# Backup database
docker-compose exec mysql mysqldump -u root -p orangehrm_mysql > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup application data
docker-compose exec orangehrm tar -czf /tmp/orangehrm_data_$(date +%Y%m%d_%H%M%S).tar.gz /var/www/html/src/config /var/www/html/src/cache
```

### Updates
```bash
# Pull latest changes
git pull

# Rebuild and restart
docker-compose down
docker-compose up -d --build

# Or use the update script
./update.sh
```

## Troubleshooting

### Common Issues

#### 1. Database Connection Failed
```bash
# Check if MySQL is running
docker-compose ps mysql

# Check MySQL logs
docker-compose logs mysql

# Test connection
docker-compose exec mysql mysql -u root -p
```

#### 2. Application Not Accessible
```bash
# Check if all services are running
docker-compose ps

# Check application logs
docker-compose logs orangehrm

# Check nginx logs
docker-compose logs nginx
```

#### 3. Permission Issues
```bash
# Fix file permissions
docker-compose exec orangehrm chown -R www-data:www-data /var/www/html
docker-compose exec orangehrm chmod -R 755 /var/www/html
docker-compose exec orangehrm chmod -R 775 /var/www/html/src/cache /var/www/html/src/log /var/www/html/src/config
```

#### 4. SSL Certificate Issues
```bash
# Check certificate validity
openssl x509 -in ssl/cert.pem -text -noout

# Regenerate self-signed certificate
rm ssl/cert.pem ssl/key.pem
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/key.pem \
    -out ssl/cert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=your-domain.com"
```

### Performance Optimization

#### 1. PHP OPcache
OPcache is already configured in the Dockerfile. Monitor with:
```bash
docker-compose exec orangehrm php -i | grep opcache
```

#### 2. MySQL Optimization
Add MySQL configuration in `mysql/init/02-optimization.sql`:
```sql
-- MySQL optimization settings
SET GLOBAL innodb_buffer_pool_size = 1G;
SET GLOBAL max_connections = 200;
SET GLOBAL query_cache_size = 64M;
```

#### 3. Nginx Caching
Static files are already configured for caching. Adjust cache duration in `nginx/conf.d/orangehrm.conf`.

## Security Considerations

### 1. Change Default Passwords
- Change MySQL root password
- Change OrangeHRM admin password
- Use strong, unique passwords

### 2. SSL/TLS
- Use valid SSL certificates in production
- Enable HSTS headers
- Use strong cipher suites

### 3. Firewall
- Only open necessary ports (22, 80, 443)
- Consider using fail2ban for additional protection

### 4. Regular Updates
- Keep Docker images updated
- Monitor security advisories
- Apply security patches promptly

## Support

For issues and support:
1. Check the logs first
2. Review this documentation
3. Check OrangeHRM official documentation
4. Create an issue in the repository

## License

This deployment configuration is provided under the same license as OrangeHRM (GPL-3.0-or-later).
