# .env File Configuration Guide

## ✅ The .env File is Nginx-Free!

**Good news:** The `.env` file contains **NO Nginx configuration** and does **NOT** install Nginx.

It only contains:
- ✅ Database credentials
- ✅ Application settings
- ✅ Admin user configuration
- ✅ Email settings (optional)
- ✅ Redis settings (optional)

---

## 🚀 Setting Up Your .env File

### Step 1: Copy the Template

On your server:

```bash
cd /opt/orangehrm

# Use the no-nginx template
cp env.no-nginx.example .env
```

Or use the standard template (both are the same, nginx-free):

```bash
cp env.example .env
```

### Step 2: Generate Secure Passwords

```bash
# Generate MySQL root password
echo "MYSQL_ROOT_PASSWORD=$(openssl rand -base64 24)"

# Generate MySQL user password
echo "MYSQL_PASSWORD=$(openssl rand -base64 16)"

# Generate encryption key (32 characters)
echo "OHRM_ENCRYPTION_KEY=$(openssl rand -base64 32)"
```

### Step 3: Edit the .env File

```bash
nano .env
```

Update these **critical** values:

```bash
# 1. Database Passwords (CHANGE THESE!)
MYSQL_ROOT_PASSWORD=<paste-generated-root-password>
MYSQL_PASSWORD=<paste-generated-user-password>
OHRM_DB_PASSWORD=<same-as-MYSQL_PASSWORD>

# 2. Encryption Key (CHANGE THIS!)
OHRM_ENCRYPTION_KEY=<paste-generated-encryption-key>

# 3. Application URL (your domain or IP)
OHRM_APP_URL=https://hrm.yourdomain.com
# Or with IP:
OHRM_APP_URL=http://your-server-ip

# 4. Admin Password (CHANGE THIS!)
OHRM_ADMIN_PASSWORD=YourSecurePassword123!

# 5. Admin Email
OHRM_ADMIN_EMAIL=admin@yourdomain.com

# 6. Organization Name
OHRM_ORG_NAME=Your Company Name
```

### Step 4: Save and Secure

```bash
# Save file (Ctrl+X, then Y, then Enter)

# Set proper permissions (only you can read)
chmod 600 .env

# Verify
ls -la .env
# Should show: -rw------- (only owner can read/write)
```

---

## 📋 Complete .env Example (For Your Setup)

```bash
# Database Configuration
MYSQL_ROOT_PASSWORD=YourSecureRootPassword123
MYSQL_DATABASE=orangehrm_mysql
MYSQL_USER=orangehrm
MYSQL_PASSWORD=YourSecureUserPassword123

# OrangeHRM Configuration
OHRM_DB_HOST=mysql
OHRM_DB_PORT=3306
OHRM_DB_NAME=orangehrm_mysql
OHRM_DB_USER=orangehrm
OHRM_DB_PASSWORD=YourSecureUserPassword123

# Application Settings
OHRM_APP_ENV=production
OHRM_APP_DEBUG=false
OHRM_APP_URL=https://hrm.yourdomain.com

# Admin User
OHRM_ADMIN_USERNAME=Admin
OHRM_ADMIN_PASSWORD=YourSecureAdminPassword123!
OHRM_ADMIN_EMAIL=admin@yourdomain.com
OHRM_ADMIN_FIRST_NAME=Admin
OHRM_ADMIN_LAST_NAME=User

# Organization
OHRM_ORG_NAME=Your Company
OHRM_ORG_COUNTRY=US

# Security
OHRM_ENCRYPTION_KEY=YourGenerated32CharacterEncryptionKey==
OHRM_SESSION_LIFETIME=3600

# Email (Optional - configure if you need email)
MAILER_DSN=smtp://smtp.gmail.com:587
MAILER_FROM_EMAIL=noreply@yourdomain.com
MAILER_FROM_NAME=Your Company HRM

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=
```

---

## ❌ What's NOT in the .env File

The `.env` file does **NOT** contain:
- ❌ No Nginx installation commands
- ❌ No Nginx configuration
- ❌ No SSL certificate paths (your Nginx handles SSL)
- ❌ No web server settings (handled by your Nginx)

The SSL paths you might see (`SSL_CERT_PATH`, `SSL_KEY_PATH`) are **NOT USED** by the Docker containers. They're just placeholders and can be ignored.

---

## 🔒 Security Best Practices

### 1. Never Commit .env to Git

The `.env` file is already in `.gitignore`. Verify:

```bash
cat .gitignore | grep .env
# Should show: .env
```

### 2. Secure File Permissions

```bash
chmod 600 .env
chown $USER:$USER .env
```

### 3. Use Strong Passwords

- **Minimum 16 characters**
- **Mix of uppercase, lowercase, numbers, symbols**
- **Different for each credential**

### 4. Regular Updates

Change passwords every 90 days:
1. Update `.env` file
2. Restart containers: `docker compose -f docker-compose.no-nginx.yml restart`
3. Update OrangeHRM admin password in the web interface

---

## 🔄 After Changing .env

Restart the containers to apply changes:

```bash
cd /opt/orangehrm

# Restart services
docker compose -f docker-compose.no-nginx.yml restart

# Or full restart
docker compose -f docker-compose.no-nginx.yml down
docker compose -f docker-compose.no-nginx.yml up -d
```

---

## 🆘 Troubleshooting

### Can't Find .env File

```bash
# Check if it exists
ls -la /opt/orangehrm/.env

# If not, create it
cd /opt/orangehrm
cp env.no-nginx.example .env
nano .env
```

### Database Connection Failed

Check if passwords match:

```bash
# These two MUST be the same
grep MYSQL_PASSWORD .env
grep OHRM_DB_PASSWORD .env
```

### View Current .env Values

```bash
cd /opt/orangehrm
cat .env
```

**⚠️ Never share your .env file - it contains sensitive passwords!**

---

## ✅ Verification Checklist

After setting up `.env`:

- [ ] File exists: `/opt/orangehrm/.env`
- [ ] Permissions: `600` (owner read/write only)
- [ ] All passwords changed from defaults
- [ ] Passwords are strong (16+ characters)
- [ ] Encryption key generated (32 characters)
- [ ] `MYSQL_PASSWORD` matches `OHRM_DB_PASSWORD`
- [ ] `OHRM_APP_URL` set to your domain/IP
- [ ] Admin email configured
- [ ] File NOT committed to git

---

## 📖 Related Files

- **env.no-nginx.example** - Clean template without Nginx references
- **env.example** - Standard template (also nginx-free)
- **SETUP_WITH_YOUR_NGINX.md** - How to configure your Nginx
- **WHICH_FILE_TO_USE.md** - Which docker-compose file to use

---

## 🎊 Summary

**The .env file is 100% safe and Nginx-free!**

It only contains:
- Database credentials
- Application settings
- Optional configurations

Your Nginx configuration is handled separately in your own Nginx server. The `.env` file does NOT install or configure Nginx! ✅
