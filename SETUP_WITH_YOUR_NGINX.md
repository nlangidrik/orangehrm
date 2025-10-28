# Setup OrangeHRM with Your Existing Nginx Server

This guide shows you how to deploy OrangeHRM **without** installing a separate Nginx container, using your existing Nginx server instead.

## 🎯 Overview

With this setup:
- ✅ OrangeHRM runs on `localhost:8080` (not exposed to internet)
- ✅ MySQL runs on `localhost:3306` (not exposed to internet)
- ✅ Your existing Nginx server proxies requests to OrangeHRM
- ✅ No Nginx container needed
- ✅ You maintain full control of your Nginx configuration

## 📋 Step-by-Step Setup

### Step 1: Deploy OrangeHRM (Without Nginx)

On your server, run:

```bash
# Clone repository
cd /opt
sudo git clone -b docker-setup https://github.com/nlangidrik/orangehrm.git
cd orangehrm
sudo chown -R $USER:$USER /opt/orangehrm

# Install Docker if needed
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# Configure environment
cp env.example .env
nano .env  # Update passwords and settings

# Deploy using the NO-NGINX configuration
docker compose -f docker-compose.no-nginx.yml up -d --build
```

### Step 2: Verify OrangeHRM is Running

```bash
# Check status
docker compose -f docker-compose.no-nginx.yml ps

# Test local access
curl -I http://localhost:8080

# You should see HTTP 200 or 302 response
```

### Step 3: Add Rate Limiting Zones to Your Nginx

Add these to the `http {}` block in your main Nginx config (usually `/etc/nginx/nginx.conf`):

```nginx
http {
    # ... your existing config ...
    
    # Rate limiting for OrangeHRM
    limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    
    # ... rest of your config ...
}
```

### Step 4: Add OrangeHRM Configuration to Your Nginx

Choose ONE of the following options based on how you want to access OrangeHRM:

#### **Option A: Subdomain (Recommended)**

Create a new config file: `/etc/nginx/sites-available/orangehrm`

```nginx
# HTTP - Redirect to HTTPS
server {
    listen 80;
    server_name hrm.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS
server {
    listen 443 ssl http2;
    server_name hrm.yourdomain.com;

    # Your SSL certificates
    ssl_certificate /etc/letsencrypt/live/hrm.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/hrm.yourdomain.com/privkey.pem;
    
    # SSL Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    # Client settings
    client_max_body_size 50M;

    # Logging
    access_log /var/log/nginx/orangehrm_access.log;
    error_log /var/log/nginx/orangehrm_error.log;

    # Proxy to OrangeHRM Docker container
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        
        proxy_buffering on;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Rate limit login attempts
    location /auth/login {
        limit_req zone=login burst=5 nodelay;
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static files with caching
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://127.0.0.1:8080;
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

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/orangehrm /etc/nginx/sites-enabled/
```

#### **Option B: Subdirectory**

Add this to your existing site config (e.g., `/etc/nginx/sites-available/default`):

```nginx
server {
    # ... your existing server config ...
    
    location /orangehrm/ {
        rewrite ^/orangehrm(.*)$ $1 break;
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        client_max_body_size 50M;
    }
}
```

#### **Option C: Main Domain**

If you want OrangeHRM as your main site, add to your domain's config:

```nginx
server {
    listen 443 ssl http2;
    server_name yourdomain.com;
    
    # Your SSL config...
    
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        client_max_body_size 50M;
    }
}
```

### Step 5: Test and Reload Nginx

```bash
# Test Nginx configuration
sudo nginx -t

# If test passes, reload Nginx
sudo systemctl reload nginx

# Or restart if needed
sudo systemctl restart nginx
```

### Step 6: Set Up SSL Certificate (If Using Subdomain)

```bash
# Install Certbot if not already installed
sudo apt install certbot python3-certbot-nginx

# Get certificate for subdomain
sudo certbot --nginx -d hrm.yourdomain.com

# Certbot will automatically update your Nginx config
```

### Step 7: Configure DNS (If Using Subdomain)

Add an A record for your subdomain:
- **Type**: A
- **Name**: hrm (or your chosen subdomain)
- **Value**: Your server's IP address
- **TTL**: 3600 (or your preference)

### Step 8: Access OrangeHRM

- **Subdomain**: https://hrm.yourdomain.com
- **Subdirectory**: https://yourdomain.com/orangehrm
- **Main domain**: https://yourdomain.com

## 🔧 Managing the Application

### Start/Stop/Restart

```bash
cd /opt/orangehrm

# Check status
docker compose -f docker-compose.no-nginx.yml ps

# Stop
docker compose -f docker-compose.no-nginx.yml down

# Start
docker compose -f docker-compose.no-nginx.yml up -d

# Restart
docker compose -f docker-compose.no-nginx.yml restart

# View logs
docker compose -f docker-compose.no-nginx.yml logs -f
```

### Create Systemd Service for Auto-Start

```bash
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

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable orangehrm
sudo systemctl start orangehrm
```

## 🔒 Security Considerations

### Firewall Configuration

Since OrangeHRM only listens on localhost, you only need to open ports for Nginx:

```bash
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw enable
```

**Important**: Do NOT open ports 8080 or 3306 on your firewall. They should only be accessible from localhost.

### Verify Ports are Not Exposed

```bash
# These should NOT be accessible from outside
sudo ss -tlnp | grep 8080
sudo ss -tlnp | grep 3306

# Both should show 127.0.0.1, not 0.0.0.0
```

## 📊 Monitoring and Logs

### View OrangeHRM Logs
```bash
cd /opt/orangehrm
docker compose -f docker-compose.no-nginx.yml logs -f orangehrm
```

### View Nginx Logs
```bash
# Access logs
sudo tail -f /var/log/nginx/orangehrm_access.log

# Error logs
sudo tail -f /var/log/nginx/orangehrm_error.log

# All Nginx logs
sudo tail -f /var/log/nginx/*.log
```

### Check Application Status
```bash
# Docker containers
docker compose -f docker-compose.no-nginx.yml ps

# Test backend connection
curl -I http://localhost:8080

# Test through Nginx
curl -I https://hrm.yourdomain.com
```

## 🔄 Updates and Maintenance

### Update OrangeHRM

```bash
cd /opt/orangehrm
git pull origin docker-setup
docker compose -f docker-compose.no-nginx.yml down
docker compose -f docker-compose.no-nginx.yml up -d --build
```

### Update Nginx Configuration

```bash
# Edit your Nginx config
sudo nano /etc/nginx/sites-available/orangehrm

# Test configuration
sudo nginx -t

# Reload if test passes
sudo systemctl reload nginx
```

### Backup Database

```bash
cd /opt/orangehrm
docker compose -f docker-compose.no-nginx.yml exec mysql mysqldump -u root -p orangehrm_mysql > backup_$(date +%Y%m%d).sql
```

## 🆘 Troubleshooting

### OrangeHRM Not Accessible Through Nginx

1. **Check Docker containers are running:**
   ```bash
   docker compose -f docker-compose.no-nginx.yml ps
   ```

2. **Test direct access to container:**
   ```bash
   curl -I http://localhost:8080
   ```

3. **Check Nginx configuration:**
   ```bash
   sudo nginx -t
   ```

4. **Check Nginx error logs:**
   ```bash
   sudo tail -f /var/log/nginx/error.log
   ```

### 502 Bad Gateway Error

This usually means Nginx can't connect to the Docker container:

```bash
# Check if OrangeHRM is running
docker compose -f docker-compose.no-nginx.yml ps

# Restart OrangeHRM
docker compose -f docker-compose.no-nginx.yml restart

# Check the container logs
docker compose -f docker-compose.no-nginx.yml logs orangehrm
```

### Nginx Can't Connect to 127.0.0.1:8080

Check if the port is bound to localhost:
```bash
sudo ss -tlnp | grep 8080
# Should show: 127.0.0.1:8080
```

If it shows `0.0.0.0:8080`, edit `docker-compose.no-nginx.yml` and change:
```yaml
ports:
  - "127.0.0.1:8080:80"  # Bind to localhost only
```

## ✅ Configuration Checklist

- [ ] Docker containers running (`docker compose ps`)
- [ ] Port 8080 accessible locally (`curl http://localhost:8080`)
- [ ] Nginx configuration added
- [ ] Nginx configuration test passed (`sudo nginx -t`)
- [ ] Nginx reloaded (`sudo systemctl reload nginx`)
- [ ] SSL certificate installed (if using HTTPS)
- [ ] DNS record added (if using subdomain)
- [ ] Firewall configured (only 22, 80, 443 open)
- [ ] Systemd service enabled for auto-start
- [ ] Application accessible via your domain

## 📝 Quick Reference

```bash
# Docker Commands (use docker-compose.no-nginx.yml)
cd /opt/orangehrm
docker compose -f docker-compose.no-nginx.yml up -d        # Start
docker compose -f docker-compose.no-nginx.yml down         # Stop
docker compose -f docker-compose.no-nginx.yml restart      # Restart
docker compose -f docker-compose.no-nginx.yml ps           # Status
docker compose -f docker-compose.no-nginx.yml logs -f      # Logs

# Nginx Commands
sudo nginx -t                           # Test config
sudo systemctl reload nginx             # Reload
sudo systemctl restart nginx            # Restart
sudo systemctl status nginx             # Status

# Check Connectivity
curl -I http://localhost:8080           # Test Docker container
curl -I https://hrm.yourdomain.com      # Test through Nginx
```

## 🎯 Summary

With this setup:
1. OrangeHRM runs in Docker, listening only on `localhost:8080`
2. Your existing Nginx proxies requests to OrangeHRM
3. All external traffic goes through your Nginx (SSL, security headers, etc.)
4. You maintain full control of your Nginx configuration
5. No separate Nginx container needed

Your existing Nginx handles all the external traffic, SSL, and security! 🔒
