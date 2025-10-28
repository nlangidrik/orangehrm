# Quick Server Commands Reference

## 🚀 One-Line Installation (Easiest Method)

SSH into your Debian server and run:

```bash
bash <(curl -s https://raw.githubusercontent.com/nlangidrik/orangehrm/docker-setup/install-production.sh)
```

This will automatically:
- ✅ Install Docker and Docker Compose
- ✅ Clone your repository
- ✅ Configure environment with secure passwords
- ✅ Set up firewall
- ✅ Create SSL certificates
- ✅ Deploy the application
- ✅ Enable auto-start on boot

---

## 📋 Manual Installation Steps

If you prefer manual installation, follow these steps:

### 1️⃣ Connect to Your Server
```bash
ssh your-username@your-server-ip
```

### 2️⃣ Install Docker
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y curl wget git apt-transport-https ca-certificates gnupg lsb-release

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes
newgrp docker

# Verify installation
docker --version
```

### 3️⃣ Install Docker Compose
```bash
# Install Docker Compose plugin
sudo apt install -y docker-compose-plugin

# Or install standalone
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify
docker compose version
```

### 4️⃣ Clone Repository
```bash
# Clone to /opt directory
cd /opt
sudo git clone -b docker-setup https://github.com/nlangidrik/orangehrm.git
cd orangehrm
sudo chown -R $USER:$USER /opt/orangehrm
```

### 5️⃣ Configure Environment
```bash
# Copy environment template
cp env.example .env

# Generate secure passwords
echo "MySQL Root Password: $(openssl rand -base64 24)"
echo "MySQL User Password: $(openssl rand -base64 16)"
echo "Encryption Key: $(openssl rand -base64 32)"

# Edit .env file with generated passwords
nano .env
```

Update these values:
- `MYSQL_ROOT_PASSWORD`
- `MYSQL_PASSWORD`
- `OHRM_DB_PASSWORD`
- `OHRM_ENCRYPTION_KEY`
- `OHRM_APP_URL`

### 6️⃣ Configure Firewall
```bash
# Install and configure UFW
sudo apt install -y ufw
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable
```

### 7️⃣ Create SSL Certificate
```bash
# Self-signed certificate
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/key.pem \
    -out ssl/cert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=your-domain.com"
```

### 8️⃣ Deploy Application
```bash
# Build and start containers
docker compose up -d --build

# Check status
docker compose ps

# View logs
docker compose logs -f
```

### 9️⃣ Enable Auto-Start
```bash
# Create systemd service
sudo tee /etc/systemd/system/orangehrm.service > /dev/null <<EOF
[Unit]
Description=OrangeHRM Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/orangehrm
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
User=$USER
Group=$USER

[Install]
WantedBy=multi-user.target
EOF

# Enable service
sudo systemctl daemon-reload
sudo systemctl enable orangehrm
sudo systemctl start orangehrm
```

---

## 🎯 Common Operations

### Start/Stop/Restart

```bash
# Navigate to project directory
cd /opt/orangehrm

# Start application
docker compose up -d

# Stop application
docker compose down

# Restart application
docker compose restart

# Restart specific service
docker compose restart orangehrm
docker compose restart mysql
```

### View Status and Logs

```bash
# Check status
docker compose ps

# View all logs
docker compose logs

# Follow logs in real-time
docker compose logs -f

# View specific service logs
docker compose logs orangehrm
docker compose logs mysql
docker compose logs nginx

# Last 50 lines
docker compose logs --tail=50
```

### Database Operations

```bash
# Access MySQL CLI
docker compose exec mysql mysql -u orangehrm -p orangehrm_mysql

# Backup database
docker compose exec mysql mysqldump -u root -p orangehrm_mysql > backup_$(date +%Y%m%d).sql

# Restore database
docker compose exec -T mysql mysql -u root -p orangehrm_mysql < backup.sql

# Check database connection
docker compose exec mysql mysqladmin ping -h localhost
```

### Container Management

```bash
# List all containers
docker ps -a

# Enter container shell
docker compose exec orangehrm bash
docker compose exec mysql bash

# Check resource usage
docker stats

# View container details
docker inspect orangehrm_app
```

### Application Updates

```bash
cd /opt/orangehrm

# Pull latest changes
git pull origin docker-setup

# Rebuild and restart
docker compose down
docker compose up -d --build

# Or use update script
./update.sh
```

### File Permissions

```bash
# Fix application permissions
docker compose exec orangehrm chown -R www-data:www-data /var/www/html
docker compose exec orangehrm chmod -R 755 /var/www/html
docker compose exec orangehrm chmod -R 775 /var/www/html/src/cache /var/www/html/src/log /var/www/html/src/config
```

---

## 🔒 Security Operations

### Change Passwords

```bash
# Edit environment file
cd /opt/orangehrm
nano .env

# Restart after changes
docker compose restart
```

### View Firewall Status

```bash
# Check UFW status
sudo ufw status verbose

# Add new rule
sudo ufw allow <port>/tcp

# Remove rule
sudo ufw delete allow <port>/tcp
```

### SSL Certificate Renewal

```bash
# For Let's Encrypt
sudo certbot renew

# Copy new certificates
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem /opt/orangehrm/ssl/cert.pem
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem /opt/orangehrm/ssl/key.pem
sudo chown $USER:$USER /opt/orangehrm/ssl/*.pem

# Restart nginx
docker compose restart nginx
```

---

## 🔧 Troubleshooting Commands

### Service Not Starting

```bash
# Check Docker service
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Check logs for errors
docker compose logs -f
```

### Port Conflicts

```bash
# Check what's using a port
sudo lsof -i :8080
sudo lsof -i :3306

# Kill process (use with caution)
sudo kill -9 <PID>
```

### Disk Space Issues

```bash
# Check disk usage
df -h

# Clean Docker system
docker system prune -a

# Remove unused volumes
docker volume prune

# Remove specific volume (⚠️ DELETES DATA)
docker volume rm orangehrm-1_mysql_data
```

### Container Health Check

```bash
# Check container health
docker inspect --format='{{.State.Health.Status}}' orangehrm_app

# View health check logs
docker inspect --format='{{range .State.Health.Log}}{{.Output}}{{end}}' orangehrm_app
```

---

## 📊 Monitoring Commands

### System Resources

```bash
# Overall system status
htop

# Docker container stats
docker stats

# Disk usage by container
docker system df

# Network usage
docker network ls
docker network inspect orangehrm-1_orangehrm_network
```

### Application Metrics

```bash
# Check Apache status
docker compose exec orangehrm apache2ctl status

# Check PHP version
docker compose exec orangehrm php -v

# Check loaded PHP modules
docker compose exec orangehrm php -m

# View PHP configuration
docker compose exec orangehrm php -i | grep -i memory
```

---

## 💾 Backup and Restore

### Full Backup

```bash
# Create backup directory
mkdir -p /opt/orangehrm/backups

# Backup database
docker compose exec mysql mysqldump -u root -p orangehrm_mysql > /opt/orangehrm/backups/db_$(date +%Y%m%d_%H%M%S).sql

# Backup application files
docker compose exec orangehrm tar -czf /tmp/app_backup.tar.gz /var/www/html/src/config
docker cp orangehrm_app:/tmp/app_backup.tar.gz /opt/orangehrm/backups/app_$(date +%Y%m%d_%H%M%S).tar.gz

# Backup .env file
cp /opt/orangehrm/.env /opt/orangehrm/backups/env_$(date +%Y%m%d_%H%M%S).backup
```

### Automated Backup Script

```bash
# Create backup script
cat > /opt/orangehrm/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/opt/orangehrm/backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR
cd /opt/orangehrm
docker compose exec -T mysql mysqldump -u root -p$MYSQL_ROOT_PASSWORD orangehrm_mysql > $BACKUP_DIR/db_$DATE.sql
docker compose exec orangehrm tar -czf /tmp/app_$DATE.tar.gz /var/www/html/src/config
docker cp orangehrm_app:/tmp/app_$DATE.tar.gz $BACKUP_DIR/
echo "Backup completed: $DATE"
EOF

# Make executable
chmod +x /opt/orangehrm/backup.sh

# Run backup
/opt/orangehrm/backup.sh

# Set up daily cron job
(crontab -l 2>/dev/null; echo "0 2 * * * /opt/orangehrm/backup.sh") | crontab -
```

---

## 🌐 Access URLs

- **Local access**: http://localhost:8080
- **Server IP**: http://YOUR_SERVER_IP:8080
- **Domain**: https://your-domain.com (after DNS configuration)

---

## 📞 Quick Help

- **Full Documentation**: `/opt/orangehrm/PRODUCTION_SETUP.md`
- **Quick Start**: `/opt/orangehrm/QUICK_START.md`
- **Deployment Guide**: `/opt/orangehrm/DEPLOYMENT.md`
- **OrangeHRM Help**: https://starterhelp.orangehrm.com

---

## ⚡ Emergency Commands

```bash
# Force stop all containers
docker compose kill

# Remove all containers and volumes (⚠️ DELETES ALL DATA)
docker compose down -v

# Restore from backup
docker compose up -d mysql
docker compose exec -T mysql mysql -u root -p orangehrm_mysql < backup.sql
docker compose up -d

# Reset to fresh install
cd /opt/orangehrm
docker compose down -v
git pull origin docker-setup
docker compose up -d --build
```

---

Remember to save this file for quick reference! 📚
