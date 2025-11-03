# Production Setup with External Nginx

This guide shows you how to deploy OrangeHRM with your own external nginx server.

## 📋 Configuration Overview

- **App Server VM** - Runs Docker containers (MySQL, OrangeHRM, Redis)
- **Nginx Server VM** - Your separate nginx server, proxies to app server on port 8080
- **Data persistence** - All configuration and data persists across rebuilds ✅

## 🖥️ Architecture

```
Internet
    ↓
[Nginx VM] (Your separate nginx server)
    ↓ (proxies to)
[App Server VM]:8080 (OrangeHRM Docker containers)
    ↓
MySQL + Redis containers (internal only)
```

## 🚀 Production Deployment Steps

### On App Server VM

### 1. Configure Environment Variables

```bash
# Create .env file
cp env.example .env

# Edit with your production values
nano .env
```

**Important values to set:**
```env
# Strong passwords!
MYSQL_ROOT_PASSWORD=your-strong-root-password
MYSQL_DATABASE=orangehrm_prod
MYSQL_USER=orangehrm_prod
MYSQL_PASSWORD=your-strong-db-password

# Admin credentials
OHRM_ADMIN_USERNAME=admin
OHRM_ADMIN_PASSWORD=your-strong-admin-password
OHRM_ADMIN_EMAIL=admin@yourcompany.com

# Application
OHRM_APP_ENV=production
OHRM_APP_DEBUG=false
OHRM_APP_URL=https://your-domain.com
```

### 2. Start OrangeHRM Docker Containers

```bash
# Start containers (without built-in nginx)
docker compose -f docker-compose.prod.yml up -d --build

# Check status
docker compose -f docker-compose.prod.yml ps

# View logs
docker compose -f docker-compose.prod.yml logs -f orangehrm
```

This will start:
- ✅ MySQL on internal network
- ✅ OrangeHRM on port **8080** (accessible to your nginx)
- ✅ Redis for sessions

### On Nginx Server VM

### 3. Configure Your External Nginx

Copy the sample config to your **nginx server** (different VM):

```bash
# On your nginx server VM
# Copy the EXTERNAL_NGINX_CONFIG.conf from the app server or create it

# Edit the config
nano /etc/nginx/sites-available/orangehrm.conf
```

**IMPORTANT: Replace YOUR_APP_SERVER_IP with actual IP**

Example IPs:
- Private network: `192.168.1.100`, `10.0.0.5`, `172.16.0.10`
- Public IP: Your app server's public IP

**Key configuration:**
```nginx
location / {
    # REPLACE with your app server IP!
    proxy_pass http://192.168.1.100:8080;  # Example: App server at 192.168.1.100
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

**Enable and restart nginx:**
```bash
# Enable the site
ln -s /etc/nginx/sites-available/orangehrm.conf /etc/nginx/sites-enabled/

# Test nginx config
nginx -t

# Reload nginx
systemctl reload nginx
```

### 4. Complete Setup Wizard (One Time Only!)

Visit your domain: https://your-domain.com

Complete the wizard with:
- **Database Host**: `mysql` (container name)
- **Database Port**: `3306`
- **Database Name**: Value from `.env` (e.g., `orangehrm_prod`)
- **Database User**: Value from `.env` (e.g., `orangehrm_prod`)
- **Database Password**: Value from `.env`

**Done!** Configuration persists forever. ✅

### 5. Verify Everything Works

```bash
# Check containers are running
docker compose -f docker-compose.prod.yml ps

# Check nginx is proxying correctly
curl -I http://localhost:8080  # Should return HTTP 200

# Check via domain
curl -I https://your-domain.com  # Should return HTTP 200
```

## 🔄 Subsequent Updates/Rebuilds

```bash
# Stop containers (data persists)
docker compose -f docker-compose.prod.yml down

# Rebuild and start
docker compose -f docker-compose.prod.yml up -d --build

# No wizard needed! Data is safe! ✅
```

## 🔒 Security Checklist

- [ ] **Strong passwords** set in `.env`
- [ ] **SSL/HTTPS** configured in nginx server
- [ ] **Firewall** rules set on BOTH VMs
- [ ] **Port 8080** only accessible from nginx server (not public)
- [ ] **Regular backups** configured
- [ ] **.env** file has proper permissions (600)

### Secure the .env file (App Server):
```bash
chmod 600 .env
chown root:root .env
```

### Firewall Setup

**On App Server VM:**
```bash
# Allow SSH
ufw allow 22/tcp

# Allow port 8080 ONLY from nginx server IP
ufw allow from NGINX_SERVER_IP to any port 8080 proto tcp

# Enable firewall
ufw enable

# Verify rules
ufw status
```

**On Nginx Server VM:**
```bash
# Allow SSH, HTTP, HTTPS
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable
```

**Example with specific IPs:**
```bash
# On App Server (192.168.1.100)
# Only allow nginx server (192.168.1.50) to access port 8080
ufw allow from 192.168.1.50 to any port 8080 proto tcp
ufw deny 8080  # Block everyone else
```

## 📦 What's Running

```
Internet
    ↓
[Nginx Server VM] (Port 80/443) ← Your separate nginx
    ↓ (proxies to app server IP)
[App Server VM]:8080
    ├─ [OrangeHRM Container] (Port 8080)
    ├─ [MySQL Container] (Internal Docker network only)
    └─ [Redis Container] (Internal Docker network only)
```

**Network Flow:**
1. User → `https://your-domain.com` → Nginx VM (port 443)
2. Nginx VM → `http://APP_SERVER_IP:8080` → App Server VM
3. App Server → Internal Docker containers (MySQL, Redis)

## 💾 Backup Strategy

### Database Backup:
```bash
# Manual backup
docker exec orangehrm_mysql mysqldump \
  -u orangehrm_prod -p'your-password' orangehrm_prod \
  > orangehrm_backup_$(date +%Y%m%d_%H%M%S).sql

# Restore from backup
docker exec -i orangehrm_mysql mysql \
  -u orangehrm_prod -p'your-password' orangehrm_prod \
  < orangehrm_backup_20250103_120000.sql
```

### Automated Daily Backup (cron):
```bash
# Add to crontab
crontab -e

# Add this line (runs at 2 AM daily)
0 2 * * * /usr/local/bin/backup-orangehrm.sh
```

**backup-orangehrm.sh:**
```bash
#!/bin/bash
BACKUP_DIR="/backups/orangehrm"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup database
docker exec orangehrm_mysql mysqldump \
  -u orangehrm_prod -p'your-password' orangehrm_prod \
  > $BACKUP_DIR/orangehrm_$DATE.sql

# Keep only last 30 days
find $BACKUP_DIR -name "orangehrm_*.sql" -mtime +30 -delete

# Optional: upload to S3, etc.
```

### Volume Backup:
```bash
# Backup all volumes
docker run --rm \
  -v orangehrm-3_orangehrm_config:/config \
  -v /backups:/backup \
  alpine tar czf /backup/orangehrm_config_$(date +%Y%m%d).tar.gz -C / config
```

## 🛠️ Useful Commands

```bash
# View logs
docker compose -f docker-compose.prod.yml logs -f

# Restart specific service
docker compose -f docker-compose.prod.yml restart orangehrm

# Check resource usage
docker stats

# Access database
docker exec -it orangehrm_mysql mysql -u orangehrm_prod -p

# Access app container shell
docker exec -it orangehrm_app bash

# Check volumes
docker volume ls | grep orangehrm

# View volume contents
docker run --rm -v orangehrm-3_orangehrm_config:/data alpine ls -la /data
```

## 📊 Monitoring (Optional)

Enable Prometheus and Grafana:

```bash
# Start with monitoring profile
docker compose -f docker-compose.prod.yml --profile monitoring up -d

# Access:
# Prometheus: http://your-server:9090
# Grafana: http://your-server:3000 (admin/admin)
```

## 🆘 Troubleshooting

### Can't access via domain

**On Nginx Server VM:**
```bash
# Check nginx is running
systemctl status nginx

# Check nginx logs
tail -f /var/log/nginx/orangehrm_error.log

# Test nginx config
nginx -t

# Test connection to app server
curl -I http://APP_SERVER_IP:8080
# Should return HTTP 200 if app server is accessible
```

**On App Server VM:**
```bash
# Check containers are running
docker compose -f docker-compose.prod.yml ps

# Check port 8080 is listening
netstat -tlnp | grep 8080
# or
ss -tlnp | grep 8080

# Test locally
curl -I http://localhost:8080

# Check firewall allows nginx server
ufw status | grep 8080
```

### Database connection errors
```bash
# Check MySQL container
docker compose -f docker-compose.prod.yml logs mysql

# Verify .env credentials match
cat .env | grep MYSQL

# Test connection
docker exec -it orangehrm_mysql mysql -u orangehrm_prod -p
```

### Still seeing wizard after rebuild
```bash
# Check if Conf.php exists
docker exec orangehrm_app ls -la /var/www/html/lib/confs/Conf.php

# Should see the file with timestamp
# If not, complete wizard once, it will persist
```

## 🎯 Production Workflow Summary

**First Time Setup:**

**On App Server VM:**
```bash
1. Configure .env with strong passwords
2. docker compose -f docker-compose.prod.yml up -d --build
3. Note your app server IP (e.g., 192.168.1.100)
```

**On Nginx Server VM:**
```bash
4. Edit nginx config, set proxy_pass to http://APP_SERVER_IP:8080
5. Enable and reload nginx
```

**Complete Setup:**
```bash
6. Visit https://your-domain.com
7. Complete wizard (one time only!)
8. Done!
```

**Updates/Rebuilds (App Server):**
```bash
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d --build
# No wizard, data persists! ✅
```

**That's it!** Your multi-VM production OrangeHRM is ready! 🚀

