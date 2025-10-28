# 🚀 Step-by-Step: Install OrangeHRM on Debian 13 with Docker

**Complete guide for installing OrangeHRM on Debian 13 using your existing Nginx server.**

---

## 📋 Prerequisites

- Debian 13 server
- Root or sudo access
- Existing Nginx server running
- Domain name or server IP address
- SSH access to your server

---

## 🎯 Installation Steps

### **Step 1: Connect to Your Server**

```bash
ssh your-username@your-server-ip
```

If you have a key file:
```bash
ssh -i /path/to/key.pem your-username@your-server-ip
```

---

### **Step 2: Update System**

```bash
# Update package list
sudo apt update

# Upgrade existing packages
sudo apt upgrade -y

# Install basic utilities
sudo apt install -y curl wget git ca-certificates gnupg lsb-release
```

---

### **Step 3: Install Docker**

```bash
# Remove any old Docker versions
sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify Docker installation
docker --version
```

Expected output: `Docker version 27.x.x, build xxxxx`

---

### **Step 4: Configure Docker Permissions**

```bash
# Add your user to docker group
sudo usermod -aG docker pssadmin

# Apply group changes
newgrp docker

# Test Docker (should work without sudo)
docker run hello-world
```

You should see: "Hello from Docker!"

---

### **Step 5: Clone OrangeHRM Repository**

```bash
# Navigate to /opt directory
cd /opt

# Clone the repository
sudo git clone -b docker-setup https://github.com/nlangidrik/orangehrm.git

# Change ownership to your user
sudo chown -R pssadmin:pssadmin /opt/orangehrm

# Navigate to project
cd orangehrm

# Verify you're on the right branch
git branch
```

You should see: `* docker-setup`

---

### **Step 6: Configure Environment Variables**

```bash
# Copy the no-nginx template
cp env.no-nginx.example .env

# Generate secure passwords
echo "=== SAVE THESE CREDENTIALS ==="
echo "MySQL Root Password: $(openssl rand -base64 24)"
echo "MySQL User Password: $(openssl rand -base64 16)"
echo "Encryption Key: $(openssl rand -base64 32)"
echo "=== SAVE THESE CREDENTIALS ==="
```

**IMPORTANT:** Copy these generated passwords to a secure location!

```bash
# Edit the .env file
nano .env
```

**Update these values:**

```bash
# Line 5-8: Database passwords
MYSQL_ROOT_PASSWORD=<paste-your-generated-root-password>
MYSQL_PASSWORD=<paste-your-generated-user-password>

# Line 15: Same as MYSQL_PASSWORD
OHRM_DB_PASSWORD=<same-as-MYSQL_PASSWORD-above>

# Line 20: Your domain or IP
OHRM_APP_URL=https://hrm.pss.edu.mh
# Or if using IP for testing:
# OHRM_APP_URL=http://192.168.84.126

# Line 24: Change admin password
OHRM_ADMIN_PASSWORD=YourSecurePassword123!

# Line 25: Your email
OHRM_ADMIN_EMAIL=admin@pss.edu.mh

# Line 31: Your company name
OHRM_ORG_NAME=Your Company Name

# Line 35: Paste your generated encryption key
OHRM_ENCRYPTION_KEY=<paste-your-generated-32-char-key>
```

**Save and exit:** Press `Ctrl+X`, then `Y`, then `Enter`

```bash
# Secure the .env file
chmod 600 .env

# Verify permissions
ls -la .env
```

Should show: `-rw-------` (only you can read/write)

---

### **Step 7: Configure Firewall**

```bash
# Install UFW if not already installed
sudo apt install -y ufw

# Allow SSH (IMPORTANT - do this first!)
sudo ufw allow 22/tcp

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow port 8080 for Nginx server to access OrangeHRM
sudo ufw allow 8080/tcp

# Enable firewall
sudo ufw --force enable

# Check status
sudo ufw status
```

Expected output:
```
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
80/tcp                     ALLOW       Anywhere
443/tcp                    ALLOW       Anywhere
8080/tcp                   ALLOW       Anywhere
```

**Port Configuration:**
- Port 8080: Must be open for your Nginx server to access OrangeHRM
- Port 3306: Keep closed (MySQL only needs local access)

---

### **Step 8: Deploy OrangeHRM (Without Nginx)**

```bash
# Make sure you're in the project directory
cd /opt/orangehrm

# Deploy using the NO-NGINX configuration
docker compose -f docker-compose.no-nginx.yml up -d --build
```

This will take 5-10 minutes on first run. You'll see:
- Building orangehrm image
- Pulling MySQL and Redis images
- Starting containers

```bash
# Wait for deployment to complete, then check status
docker compose -f docker-compose.no-nginx.yml ps
```

Expected output:
```
NAME              IMAGE                   STATUS
orangehrm_app     orangehrm-1-orangehrm   Up
orangehrm_mysql   mysql:8.0               Up (healthy)
orangehrm_redis   redis:7-alpine          Up
```

**You should NOT see any nginx container!**

---

### **Step 9: Verify OrangeHRM is Running**

```bash
# Test if MySQL is ready
docker compose -f docker-compose.no-nginx.yml exec mysql mysqladmin ping -h localhost
```

Expected: `mysqld is alive`

```bash
# Test if OrangeHRM is accessible locally
curl -I http://localhost:8080
```

Expected: `HTTP/1.1 200 OK` or `HTTP/1.1 302 Found`

```bash
# Check container logs
docker compose -f docker-compose.no-nginx.yml logs orangehrm --tail=50
```

Look for: `Apache/2.4.x ... configured -- resuming normal operations`

```bash
# Verify ports are bound to localhost only
sudo ss -tlnp | grep -E '8080|3306'
```

Expected (since Nginx is on a different server):
```
0.0.0.0:8080 or 192.168.84.126:8080  (accessible on network for Nginx)
127.0.0.1:3306    (NOT 0.0.0.0:3306 - MySQL stays local)
```

**Note:** Port 8080 needs to be accessible from your Nginx server, so it should NOT be bound to 127.0.0.1 only.

---

### **Step 10: Configure Your Existing Nginx**

#### **Option A: Using a Subdomain (Recommended)**

```bash
# Create Nginx config for OrangeHRM
sudo nano /etc/nginx/sites-available/orangehrm
```

**Paste this configuration:**

```nginx
# HTTP - Redirect to HTTPS
server {
    listen 80;
    server_name hrm.pss.edu.mh;
    return 301 https://$server_name$request_uri;
}

# HTTPS
server {
    listen 443 ssl http2;
    server_name hrm.pss.edu.mh;

    # SSL certificates (update paths if different)
    ssl_certificate /etc/letsencrypt/live/hrm.pss.edu.mh/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/hrm.pss.edu.mh/privkey.pem;
    
    # SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    # Client settings
    client_max_body_size 50M;

    # Logging
    access_log /var/log/nginx/orangehrm_access.log;
    error_log /var/log/nginx/orangehrm_error.log;

    # Proxy to OrangeHRM Docker container (on different server)
    location / {
        proxy_pass http://192.168.84.126:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        
        # Buffer settings
        proxy_buffering on;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Static files with caching
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://192.168.84.126:8080;
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Deny sensitive directories
    location ~ /(src|installer|devTools|build)/ {
        deny all;
        return 404;
    }
}
```

**Note:** Configuration is already set for `hrm.pss.edu.mh` and server IP `192.168.84.126`

```bash
# Enable the site
sudo ln -s /etc/nginx/sites-available/orangehrm /etc/nginx/sites-enabled/

# Test Nginx configuration
sudo nginx -t
```

Expected: `test is successful`

```bash
# Reload Nginx
sudo systemctl reload nginx
```

#### **Option B: Using Subdirectory** (if you prefer `/orangehrm` path)

Edit your existing site config:
```bash
sudo nano /etc/nginx/sites-available/default
```

Add this location block inside your existing `server {}` block:

```nginx
location /orangehrm/ {
    rewrite ^/orangehrm(.*)$ $1 break;
    proxy_pass http://192.168.84.126:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    client_max_body_size 50M;
}
```

Then reload Nginx:
```bash
sudo nginx -t && sudo systemctl reload nginx
```

---

### **Step 11: Set Up SSL Certificate (If Using Subdomain)**

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d hrm.pss.edu.mh

# Follow the prompts:
# - Enter your email
# - Agree to terms
# - Choose whether to redirect HTTP to HTTPS (recommended: Yes)
```

Certbot will automatically update your Nginx configuration!

**Note:** Make sure your domain's DNS A record points to your server IP before running certbot.

---

### **Step 12: Configure DNS (If Using Subdomain)**

In your domain registrar or DNS provider, add:

- **Type:** A
- **Name:** hrm
- **Value:** 192.168.84.126
- **TTL:** 3600 (or default)

Wait 5-10 minutes for DNS to propagate.

---

### **Step 13: Access OrangeHRM Web Installer**

Open your browser and navigate to:

- **With subdomain:** `https://hrm.pss.edu.mh`
- **With subdirectory:** `https://pss.edu.mh/orangehrm`
- **With IP (testing):** `http://192.168.84.126:8080`

You should see the OrangeHRM installation wizard!

---

### **Step 14: Complete OrangeHRM Installation**

Follow the web installer:

1. **Welcome Screen**
   - Click "Next"

2. **License Agreement**
   - Check "I accept the terms in the License Agreement"
   - Click "Next"

3. **Database Configuration**
   - Host Name: `mysql`
   - Port: `3306`
   - Database Name: `orangehrm_mysql`
   - Database User: `orangehrm`
   - Database Password: (from your `.env` file - `MYSQL_PASSWORD`)
   - Click "Next"

4. **System Check**
   - All checks should pass (green)
   - Click "Next"

5. **Admin User Setup**
   - Employee First Name: Your name
   - Employee Last Name: Your surname
   - Admin Username: `Admin` (or your preference)
   - Admin Password: Choose a strong password
   - Confirm Password: Re-enter password
   - Email: Your email address
   - Click "Next"

6. **Confirmation**
   - Review your settings
   - Check "I have read and agree..."
   - Click "Install"

7. **Installation Progress**
   - Wait while database is created and populated
   - This takes 2-3 minutes

8. **Installation Complete**
   - Click "Next" to go to login page

---

### **Step 15: Log In to OrangeHRM**

- **Username:** Admin (or what you chose)
- **Password:** Your admin password

**IMPORTANT:** Change your admin password immediately after first login!

---

### **Step 16: Enable Auto-Start on Server Reboot**

```bash
# Create systemd service
sudo tee /etc/systemd/system/orangehrm.service > /dev/null <<EOF
[Unit]
Description=OrangeHRM Docker Compose
Requires=docker.service
After=docker.service network.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/orangehrm
ExecStart=/usr/bin/docker compose -f docker-compose.no-nginx.yml up -d
ExecStop=/usr/bin/docker compose -f docker-compose.no-nginx.yml down
User=$USER
Group=$USER

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
sudo systemctl daemon-reload

# Enable auto-start
sudo systemctl enable orangehrm

# Check status
sudo systemctl status orangehrm
```

Expected: `Loaded: loaded ... enabled`

---

### **Step 17: Set Up Automated Backups (Recommended)**

```bash
# Create backup script
nano /opt/orangehrm/backup.sh
```

**Paste this:**

```bash
#!/bin/bash
BACKUP_DIR="/opt/orangehrm/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
cd /opt/orangehrm

# Backup database
docker compose -f docker-compose.no-nginx.yml exec -T mysql mysqldump -u root -p$MYSQL_ROOT_PASSWORD orangehrm_mysql > $BACKUP_DIR/db_$DATE.sql

# Backup configuration
cp .env $BACKUP_DIR/env_$DATE.backup

echo "Backup completed: $DATE"

# Keep only last 7 days of backups
find $BACKUP_DIR -name "db_*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "env_*.backup" -mtime +7 -delete
```

```bash
# Make executable
chmod +x /opt/orangehrm/backup.sh

# Test backup
/opt/orangehrm/backup.sh
```

```bash
# Set up daily backups at 2 AM
crontab -e
```

Add this line:
```
0 2 * * * /opt/orangehrm/backup.sh
```

Save and exit.

---

## ✅ **Installation Complete!**

Your OrangeHRM is now:
- ✅ Running on Docker
- ✅ Accessible via your Nginx
- ✅ Secured with SSL (if configured)
- ✅ Set to auto-start on reboot
- ✅ Backed up daily

---

## 🔧 **Useful Commands**

```bash
# Navigate to project
cd /opt/orangehrm

# View status
docker compose -f docker-compose.no-nginx.yml ps

# View logs (all services)
docker compose -f docker-compose.no-nginx.yml logs -f

# View OrangeHRM logs only
docker compose -f docker-compose.no-nginx.yml logs -f orangehrm

# Restart all services
docker compose -f docker-compose.no-nginx.yml restart

# Restart specific service
docker compose -f docker-compose.no-nginx.yml restart orangehrm

# Stop all services
docker compose -f docker-compose.no-nginx.yml down

# Start all services
docker compose -f docker-compose.no-nginx.yml up -d

# Update application
git pull origin docker-setup
docker compose -f docker-compose.no-nginx.yml down
docker compose -f docker-compose.no-nginx.yml up -d --build
```

---

## 🆘 **Troubleshooting**

### Application Not Loading

```bash
# Check if containers are running
docker compose -f docker-compose.no-nginx.yml ps

# Check logs for errors
docker compose -f docker-compose.no-nginx.yml logs orangehrm

# Restart services
docker compose -f docker-compose.no-nginx.yml restart
```

### 502 Bad Gateway

```bash
# Check if OrangeHRM is accessible locally
curl -I http://localhost:8080

# Check Nginx error logs
sudo tail -f /var/log/nginx/error.log

# Restart OrangeHRM
docker compose -f docker-compose.no-nginx.yml restart orangehrm
```

### Database Connection Failed

```bash
# Check MySQL is running
docker compose -f docker-compose.no-nginx.yml ps mysql

# Check MySQL logs
docker compose -f docker-compose.no-nginx.yml logs mysql

# Verify credentials in .env
cat /opt/orangehrm/.env | grep PASSWORD
```

### Can't Access via Domain

```bash
# Check Nginx is running
sudo systemctl status nginx

# Test Nginx config
sudo nginx -t

# Check DNS
dig hrm.pss.edu.mh

# Check firewall
sudo ufw status
```

---

## 🔒 **Security Checklist**

After installation:

- [ ] All default passwords changed
- [ ] .env file secured (chmod 600)
- [ ] Firewall enabled (only ports 22, 80, 443 open)
- [ ] SSL certificate installed
- [ ] Admin password changed in OrangeHRM
- [ ] Backups tested and working
- [ ] Auto-start enabled
- [ ] Application accessible via domain

---

## 📚 **Next Steps**

1. **Configure Organization Settings** in OrangeHRM
2. **Add Employees and Users**
3. **Set up Email Configuration** (if needed)
4. **Customize** OrangeHRM to your needs
5. **Train your team**

---

## 📞 **Support**

- **Documentation:** `/opt/orangehrm/SETUP_WITH_YOUR_NGINX.md`
- **Commands:** `/opt/orangehrm/SERVER_COMMANDS.md`
- **OrangeHRM Help:** https://starterhelp.orangehrm.com

---

**Congratulations! Your OrangeHRM is now running on Docker! 🎉**
