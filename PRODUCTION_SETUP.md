# OrangeHRM Production Setup Guide for Debian Server

Complete step-by-step guide to deploy OrangeHRM on your Debian production server.

## 📋 Prerequisites

- Debian 10/11/12 or Ubuntu 20.04+ server
- Root or sudo access
- Minimum 2GB RAM (4GB+ recommended)
- Minimum 20GB disk space
- Domain name (optional but recommended)

## 🚀 Step-by-Step Installation

### Step 1: Connect to Your Server

```bash
# SSH into your Debian server
ssh your-username@your-server-ip

# Or if you have a key file
ssh -i /path/to/key.pem your-username@your-server-ip
```

### Step 2: Update System Packages

```bash
# Update package list
sudo apt update

# Upgrade existing packages
sudo apt upgrade -y

# Install basic utilities
sudo apt install -y curl wget git apt-transport-https ca-certificates gnupg lsb-release
```

### Step 3: Install Docker

```bash
# Remove any old Docker installations
sudo apt remove docker docker-engine docker.io containerd runc

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify Docker installation
sudo docker --version

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group (to run docker without sudo)
sudo usermod -aG docker $USER

# Apply group changes (logout and login, or run)
newgrp docker

# Test Docker
docker run hello-world
```

### Step 4: Install Docker Compose

```bash
# Docker Compose should be installed with docker-compose-plugin
# Verify installation
docker compose version

# If not installed, install it manually
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

### Step 5: Clone Your Repository

```bash
# Navigate to your preferred directory
cd /opt

# Clone your OrangeHRM repository
sudo git clone https://github.com/nlangidrik/orangehrm.git

# Change to project directory
cd orangehrm

# Checkout the docker-setup branch
sudo git checkout docker-setup

# Set proper permissions
sudo chown -R $USER:$USER /opt/orangehrm
```

### Step 6: Configure Environment Variables

```bash
# Copy environment template
cp env.example .env

# Edit environment file with secure passwords
nano .env
```

**Update these critical values in `.env`:**

```bash
# Generate strong passwords
MYSQL_ROOT_PASSWORD=<generate-strong-password-here>
MYSQL_PASSWORD=<generate-strong-password-here>

# Update application URL to your domain or IP
OHRM_APP_URL=http://your-domain.com

# Change admin password
OHRM_ADMIN_PASSWORD=<your-strong-admin-password>

# Generate encryption key (32 characters)
OHRM_ENCRYPTION_KEY=<generate-32-character-key>
```

**To generate strong passwords and keys:**

```bash
# Generate random password
openssl rand -base64 24

# Generate 32-character encryption key
openssl rand -base64 32
```

Save and exit (Ctrl+X, then Y, then Enter)

### Step 7: Configure Firewall

```bash
# Install UFW if not already installed
sudo apt install -y ufw

# Allow SSH (IMPORTANT - do this first!)
sudo ufw allow 22/tcp

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw --force enable

# Check firewall status
sudo ufw status
```

### Step 8: Create SSL Certificates

#### Option A: Self-Signed Certificate (for testing/internal use)

```bash
# Create SSL directory
mkdir -p ssl

# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout ssl/key.pem \
    -out ssl/cert.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=your-domain.com"
```

#### Option B: Let's Encrypt (for production with domain)

```bash
# Install Certbot
sudo apt install -y certbot

# Stop any service on port 80
sudo systemctl stop nginx apache2

# Generate certificate
sudo certbot certonly --standalone -d your-domain.com -d www.your-domain.com

# Copy certificates to project
mkdir -p ssl
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem ssl/key.pem
sudo chown $USER:$USER ssl/*.pem
```

### Step 9: Update Nginx Configuration

```bash
# Edit Nginx configuration with your domain
nano nginx/conf.d/orangehrm.conf
```

**Update this line:**
```nginx
server_name your-domain.com www.your-domain.com;
```

Replace `your-domain.com` with your actual domain or server IP.

### Step 10: Deploy the Application

```bash
# Make deployment script executable
chmod +x deploy.sh

# Run the deployment script (automated)
./deploy.sh
```

**OR manually deploy:**

```bash
# Build and start containers
docker compose -f docker-compose.yml up -d --build

# Check container status
docker compose ps

# View logs
docker compose logs -f
```

### Step 11: Wait for Services to Start

```bash
# Check if MySQL is ready
docker compose exec mysql mysqladmin ping -h localhost --silent && echo "MySQL is ready"

# Check if OrangeHRM is accessible (may take 1-2 minutes)
curl -I http://localhost:8080

# Monitor logs until application starts
docker compose logs -f orangehrm
```

Press Ctrl+C to stop viewing logs once you see Apache has started.

### Step 12: Access and Configure OrangeHRM

1. Open your browser and navigate to:
   - With domain: `https://your-domain.com`
   - With IP: `http://your-server-ip:8080`

2. Follow the installation wizard:

   **Database Configuration:**
   - Host Name: `mysql`
   - Port: `3306`
   - Database Name: `orangehrm_mysql`
   - Database User: `orangehrm`
   - Database Password: (use the value from your `.env` file)

   **Admin User:**
   - Create your admin account with a strong password

3. Complete the installation

### Step 13: Set Up Auto-Start on Boot

```bash
# Create systemd service
sudo nano /etc/systemd/system/orangehrm.service
```

**Add this content:**

```ini
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
User=your-username
Group=your-username

[Install]
WantedBy=multi-user.target
```

Replace `your-username` with your actual username.

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable auto-start
sudo systemctl enable orangehrm

# Start the service
sudo systemctl start orangehrm

# Check status
sudo systemctl status orangehrm
```

## 🔒 Security Hardening

### 1. Change Default Passwords

```bash
# In your .env file, ensure all passwords are strong and unique
nano .env
```

### 2. Set Up Automatic Updates

```bash
# Install unattended-upgrades
sudo apt install -y unattended-upgrades

# Enable automatic security updates
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 3. Configure Fail2Ban (Protection against brute-force)

```bash
# Install Fail2Ban
sudo apt install -y fail2ban

# Create custom configuration
sudo nano /etc/fail2ban/jail.local
```

**Add:**

```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = 22

[nginx-http-auth]
enabled = true
```

```bash
# Restart Fail2Ban
sudo systemctl restart fail2ban
sudo systemctl enable fail2ban
```

### 4. Regular Backups

```bash
# Create backup script
nano /opt/orangehrm/backup.sh
```

**Add:**

```bash
#!/bin/bash
BACKUP_DIR="/opt/orangehrm/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup database
docker compose exec -T mysql mysqldump -u root -p$MYSQL_ROOT_PASSWORD orangehrm_mysql > $BACKUP_DIR/db_$DATE.sql

# Backup application files
docker compose exec orangehrm tar -czf /tmp/app_$DATE.tar.gz /var/www/html/src/config
docker cp orangehrm_app:/tmp/app_$DATE.tar.gz $BACKUP_DIR/

echo "Backup completed: $DATE"
```

```bash
# Make executable
chmod +x /opt/orangehrm/backup.sh

# Set up cron job for daily backups
crontab -e
```

**Add this line:**
```
0 2 * * * /opt/orangehrm/backup.sh
```

## 📊 Monitoring and Maintenance

### Check Application Status

```bash
# View running containers
docker compose ps

# Check container health
docker compose ps --format "table {{.Name}}\t{{.Status}}"

# View logs
docker compose logs -f

# Check resource usage
docker stats
```

### Update Application

```bash
cd /opt/orangehrm

# Pull latest changes
git pull origin docker-setup

# Rebuild and restart
docker compose down
docker compose up -d --build
```

### Restart Services

```bash
# Restart all services
docker compose restart

# Restart specific service
docker compose restart orangehrm
docker compose restart mysql
```

## 🔧 Troubleshooting

### Check Logs

```bash
# All logs
docker compose logs

# Specific service logs
docker compose logs orangehrm
docker compose logs mysql
docker compose logs nginx

# Follow logs in real-time
docker compose logs -f
```

### Database Connection Issues

```bash
# Check if MySQL is running
docker compose ps mysql

# Test MySQL connection
docker compose exec mysql mysql -u orangehrm -p orangehrm_mysql

# Check MySQL logs
docker compose logs mysql
```

### Permissions Issues

```bash
# Fix file permissions
docker compose exec orangehrm chown -R www-data:www-data /var/www/html
docker compose exec orangehrm chmod -R 755 /var/www/html
docker compose exec orangehrm chmod -R 775 /var/www/html/src/cache /var/www/html/src/log /var/www/html/src/config
```

### Port Conflicts

```bash
# Check what's using port 8080
sudo lsof -i :8080

# Check what's using port 3306
sudo lsof -i :3306

# Kill process if needed
sudo kill -9 <PID>
```

## 📞 Quick Commands Reference

```bash
# Navigate to project
cd /opt/orangehrm

# Start services
docker compose up -d

# Stop services
docker compose down

# Restart services
docker compose restart

# View logs
docker compose logs -f

# Check status
docker compose ps

# Update and restart
git pull && docker compose up -d --build

# Backup database
docker compose exec mysql mysqldump -u root -p orangehrm_mysql > backup.sql

# Access MySQL
docker compose exec mysql mysql -u orangehrm -p orangehrm_mysql

# Clean up unused Docker resources
docker system prune -a
```

## ✅ Post-Installation Checklist

- [ ] Application is accessible via browser
- [ ] SSL certificate is installed (if using HTTPS)
- [ ] All default passwords have been changed
- [ ] Firewall is configured and enabled
- [ ] Auto-start on boot is enabled
- [ ] Backup script is set up and tested
- [ ] Fail2Ban is configured
- [ ] DNS records point to server (if using domain)
- [ ] Admin user created and tested
- [ ] Email configuration tested (if needed)

## 🎉 Success!

Your OrangeHRM application should now be running on your production Debian server!

Access it at:
- **With domain**: https://your-domain.com
- **With IP**: http://your-server-ip:8080

For support, check:
- Application logs: `docker compose logs -f`
- Documentation: `DEPLOYMENT.md` and `QUICK_START.md`
- OrangeHRM Help: https://starterhelp.orangehrm.com
