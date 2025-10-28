# ⚠️ IMPORTANT: Which Docker Compose File to Use

## 🚨 For Your Setup (Using Your Own Nginx)

### ✅ **USE THIS FILE:**
```bash
docker-compose.no-nginx.yml
```

This file does **NOT** install or run Nginx. It only runs:
- ✅ OrangeHRM (Apache + PHP)
- ✅ MySQL
- ✅ Redis
- ❌ **NO NGINX** (you use your own)

---

## 📋 File Comparison

| File | Has Nginx Container? | When to Use |
|------|---------------------|-------------|
| **docker-compose.no-nginx.yml** | ❌ **NO** | **Use this when you have your own Nginx** |
| docker-compose.simple.yml | ❌ NO | Simple setup for testing (no Nginx) |
| docker-compose.yml | ✅ YES | Full setup with Nginx container |
| docker-compose.prod.yml | ✅ YES | Production with Nginx + monitoring |

---

## 🎯 Your Deployment Commands

### Use ONLY these commands:

```bash
# Navigate to project
cd /opt/orangehrm

# Start (NO NGINX INSTALLED)
docker compose -f docker-compose.no-nginx.yml up -d --build

# Stop
docker compose -f docker-compose.no-nginx.yml down

# Restart
docker compose -f docker-compose.no-nginx.yml restart

# View logs
docker compose -f docker-compose.no-nginx.yml logs -f

# Check status
docker compose -f docker-compose.no-nginx.yml ps
```

---

## 🔒 What Gets Exposed

With `docker-compose.no-nginx.yml`:

- **Port 8080**: Bound to `127.0.0.1:8080` (localhost only)
- **Port 3306**: Bound to `127.0.0.1:3306` (localhost only)

**Both ports are ONLY accessible from localhost**, not from the internet.

Your Nginx server will proxy requests to `http://127.0.0.1:8080`.

---

## ❌ Files to AVOID

**DO NOT USE these files** (they install Nginx):

- ❌ `docker-compose.yml` - Contains Nginx container
- ❌ `docker-compose.prod.yml` - Contains Nginx container
- ❌ `deploy.sh` - May use docker-compose.yml with Nginx

---

## ✅ Verification Checklist

After running `docker compose -f docker-compose.no-nginx.yml up -d`:

```bash
# 1. Check running containers (should NOT see nginx)
docker ps

# Should show ONLY:
# - orangehrm_mysql
# - orangehrm_app
# - orangehrm_redis
# Should NOT show: orangehrm_nginx

# 2. Verify ports are localhost-only
sudo ss -tlnp | grep 8080
# Should show: 127.0.0.1:8080 (NOT 0.0.0.0:8080)

sudo ss -tlnp | grep 3306
# Should show: 127.0.0.1:3306 (NOT 0.0.0.0:3306)

# 3. Test local access
curl -I http://localhost:8080
# Should return HTTP 200 or 302

# 4. Verify Nginx is NOT running in Docker
docker ps | grep nginx
# Should return NOTHING
```

---

## 📖 Related Documentation

- **SETUP_WITH_YOUR_NGINX.md** - How to configure your existing Nginx
- **nginx/YOUR_NGINX_CONFIG.conf** - Nginx config examples
- **SERVER_COMMANDS.md** - Command reference

---

## 🎊 Summary

### ✅ What You're Getting:
- OrangeHRM running on localhost:8080
- MySQL running on localhost:3306
- Redis for sessions
- **NO NGINX INSTALLATION**
- You configure your own Nginx to proxy to localhost:8080

### ❌ What You're NOT Getting:
- No Nginx container
- No automatic SSL setup
- No additional web server

**Your existing Nginx handles everything! 🎉**
