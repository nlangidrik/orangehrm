# 🚀 OrangeHRM Production Deployment Guide

This guide provides the simplest way to deploy OrangeHRM on your Debian production server.

## ⚡ Quick Start (Easiest Method)

### Step 1: SSH into Your Server
```bash
ssh your-username@your-server-ip
```

### Step 2: Run the Automated Installer
```bash
bash <(curl -s https://raw.githubusercontent.com/nlangidrik/orangehrm/docker-setup/install-production.sh)
```

That's it! The script will automatically:
- ✅ Install Docker and Docker Compose
- ✅ Clone and configure the application
- ✅ Set up firewall and SSL
- ✅ Deploy OrangeHRM
- ✅ Configure auto-start on boot

### Step 3: Access Your Application

After installation completes, open your browser:
```
http://YOUR_SERVER_IP:8080
```

Follow the web installer with these database credentials:
- **Host**: `mysql`
- **Port**: `3306`
- **Database**: `orangehrm_mysql`
- **Username**: `orangehrm`
- **Password**: (shown during installation or check `/opt/orangehrm/.env`)

## 📚 Available Documentation

| Document | Purpose |
|----------|---------|
| **SERVER_COMMANDS.md** | Quick command reference for managing the server |
| **PRODUCTION_SETUP.md** | Detailed step-by-step manual installation guide |
| **QUICK_START.md** | Quick start guide for using OrangeHRM |
| **DEPLOYMENT.md** | Comprehensive deployment documentation |

## 🔑 Important Information

### Default Locations
- **Installation Directory**: `/opt/orangehrm`
- **Configuration File**: `/opt/orangehrm/.env`
- **Backups**: `/opt/orangehrm/backups`
- **SSL Certificates**: `/opt/orangehrm/ssl`

### Database Credentials
All credentials are stored in: `/opt/orangehrm/.env`

To view them:
```bash
cat /opt/orangehrm/.env | grep PASSWORD
```

### Access Ports
- **Application**: Port 8080 (HTTP)
- **HTTPS**: Port 443 (with Nginx)
- **MySQL**: Port 3306 (internal only)

## 🛠️ Common Management Commands

### Navigate to Project
```bash
cd /opt/orangehrm
```

### Check Status
```bash
docker compose ps
```

### View Logs
```bash
docker compose logs -f
```

### Stop Application
```bash
docker compose down
```

### Start Application
```bash
docker compose up -d
```

### Restart Application
```bash
docker compose restart
```

### Backup Database
```bash
docker compose exec mysql mysqldump -u root -p orangehrm_mysql > backup.sql
```

### Update Application
```bash
cd /opt/orangehrm
git pull origin docker-setup
docker compose up -d --build
```

## 🔐 Security Checklist

After installation, ensure you:

- [ ] Change default admin password in OrangeHRM
- [ ] Review and secure passwords in `.env` file
- [ ] Set up SSL certificate (Let's Encrypt for production)
- [ ] Configure firewall rules (UFW)
- [ ] Set up regular backups (cron job)
- [ ] Update server packages regularly
- [ ] Monitor application logs

## 🆘 Troubleshooting

### Application Not Loading
```bash
# Check if containers are running
docker compose ps

# View error logs
docker compose logs orangehrm

# Restart application
docker compose restart
```

### Database Connection Issues
```bash
# Check MySQL status
docker compose ps mysql

# Test database connection
docker compose exec mysql mysql -u orangehrm -p orangehrm_mysql
```

### Port Already in Use
```bash
# Find what's using the port
sudo lsof -i :8080

# Kill the process
sudo kill -9 <PID>
```

## 🔄 Update Guide

To update to the latest version:

```bash
# Navigate to project
cd /opt/orangehrm

# Pull latest changes
git pull origin docker-setup

# Stop containers
docker compose down

# Rebuild and start
docker compose up -d --build

# Verify status
docker compose ps
```

## 💾 Backup Guide

### Manual Backup
```bash
cd /opt/orangehrm
./backup.sh
```

### Automated Daily Backup
The installation script sets up automatic daily backups at 2 AM.

To verify:
```bash
crontab -l
```

### Restore from Backup
```bash
cd /opt/orangehrm
docker compose exec -T mysql mysql -u root -p orangehrm_mysql < backup.sql
```

## 🌐 Domain Configuration

### With Domain Name

1. Point your domain DNS to your server IP:
   - A record: `your-domain.com` → `YOUR_SERVER_IP`
   - A record: `www.your-domain.com` → `YOUR_SERVER_IP`

2. Install Let's Encrypt SSL:
```bash
sudo apt install -y certbot
sudo certbot certonly --standalone -d your-domain.com -d www.your-domain.com
```

3. Update nginx configuration:
```bash
nano /opt/orangehrm/nginx/conf.d/orangehrm.conf
```

Change `server_name` to your domain.

4. Restart nginx:
```bash
docker compose restart nginx
```

## 📊 Monitoring

### View Real-time Logs
```bash
docker compose logs -f
```

### Check Resource Usage
```bash
docker stats
```

### View Systemd Service Status
```bash
sudo systemctl status orangehrm
```

## 🎯 Performance Tuning

For production use, consider:

1. **Increase PHP memory limit** (in `Dockerfile.production`)
2. **Optimize MySQL** (in `docker-compose.yml`)
3. **Enable Redis caching** (already configured)
4. **Set up CDN** for static assets
5. **Use dedicated database server** for large deployments

## 📞 Support and Resources

- **OrangeHRM Documentation**: https://starterhelp.orangehrm.com
- **Docker Documentation**: https://docs.docker.com
- **Your Deployment Docs**: `/opt/orangehrm/PRODUCTION_SETUP.md`

## 🎉 Success Indicators

Your deployment is successful when:

✅ Containers are running: `docker compose ps` shows all services "Up"
✅ Application accessible: Browser opens the OrangeHRM installer
✅ Database connected: Installation wizard can connect to MySQL
✅ Auto-start enabled: `sudo systemctl status orangehrm` shows "enabled"
✅ Firewall active: `sudo ufw status` shows rules configured

---

## 📝 Quick Reference Card

```bash
# Essential Commands
cd /opt/orangehrm              # Go to project directory
docker compose ps              # Check status
docker compose logs -f         # View logs
docker compose restart         # Restart all services
docker compose down            # Stop all services
docker compose up -d           # Start all services
sudo systemctl restart orangehrm  # Restart using systemd

# Database
docker compose exec mysql mysql -u orangehrm -p  # Access MySQL
docker compose exec mysql mysqldump -u root -p orangehrm_mysql > backup.sql  # Backup

# Updates
git pull origin docker-setup && docker compose up -d --build  # Update app

# Troubleshooting
docker compose logs orangehrm --tail=100  # Last 100 log lines
docker stats                    # Resource usage
sudo systemctl status docker    # Docker service status
```

---

**Ready to deploy? Just run the one-line installer command and you're good to go!** 🚀

For detailed manual installation, see `PRODUCTION_SETUP.md`.
