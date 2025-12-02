# Production Server Update Guide

This guide walks you through updating your OrangeHRM production server with the latest changes from the main branch.

## ⚠️ IMPORTANT: Read Before Starting

- **Always backup before updating**
- **Schedule updates during low-traffic periods**
- **Test in staging first if possible**
- **Have a rollback plan ready**

---

## 📋 Pre-Update Checklist

- [ ] Backup database
- [ ] Backup application files
- [ ] Verify disk space (need at least 5GB free)
- [ ] Check current container status
- [ ] Notify users of maintenance window (if needed)

---

## 🚀 Step-by-Step Update Process

### Step 1: Connect to Your Production Server

```bash
ssh your-username@your-production-server-ip
```

### Step 2: Navigate to Application Directory

```bash
cd /opt/orangehrm
# Or wherever your application is installed
```

### Step 3: Check Current Status

```bash
# Check what branch you're on
git branch

# Check current container status
docker compose ps

# Check for uncommitted changes
git status
```

**If you have uncommitted changes to `.env` or `docker-compose.yml`:**

```bash
# Option 1: Stash changes (recommended - keeps your local config)
git stash push -m "Local production config before update"

# Option 2: Commit changes if they're important
git add .env docker-compose.yml
git commit -m "Production configuration updates"

# Option 3: Discard changes if you want to use the repo version
# WARNING: This will overwrite your local .env file!
# git restore .env docker-compose.yml
```

### Step 4: Create Database Backup ⚠️ CRITICAL

```bash
# Create backup directory with timestamp (in current directory or use absolute path)
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR" || {
    # If permission denied, try with sudo or use home directory
    BACKUP_DIR="$HOME/orangehrm_backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    echo "Using backup directory: $BACKUP_DIR"
}

# Backup database
echo "Creating database backup..."
# Get password from .env file (handle both formats: MYSQL_PASSWORD=value and MYSQL_PASSWORD = value)
DB_PASSWORD=$(grep "^MYSQL_PASSWORD" .env | cut -d '=' -f2 | tr -d ' ' | tr -d '"')
docker compose exec mysql mysqldump -u orangehrm -p"$DB_PASSWORD" orangehrm_mysql > "$BACKUP_DIR/database.sql"

# Verify backup was created
if [ -f "$BACKUP_DIR/database.sql" ]; then
    ls -lh "$BACKUP_DIR/database.sql"
    echo "✅ Database backup created: $BACKUP_DIR/database.sql"
else
    echo "❌ Backup failed! Check permissions and try again."
    exit 1
fi
```

**Alternative backup method:**
```bash
# If you have the backup script
./backup-database.sh

# Or using docker directly
docker exec orangehrm_mysql mysqldump -u orangehrm -p$(grep MYSQL_PASSWORD .env | cut -d '=' -f2) orangehrm_mysql > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Step 5: Backup Application Configuration

```bash
# Backup configuration files
cp lib/confs/Conf.php "$BACKUP_DIR/Conf.php" 2>/dev/null || echo "No Conf.php found (first install)"

# Backup .env file (if exists)
cp .env "$BACKUP_DIR/.env" 2>/dev/null || echo "No .env file"

echo "✅ Configuration backed up"
```

### Step 6: Pull Latest Changes from Main Branch

```bash
# Fetch latest changes
git fetch origin

# Check what will be updated
git log HEAD..origin/main --oneline

# Pull latest changes from main branch
# If you stashed changes in Step 3, they will be preserved
git pull origin main

# If you stashed changes, reapply them now
git stash pop 2>/dev/null || echo "No stashed changes to restore"

# Verify you're on the latest commit
git log -1 --oneline
```

**Note:** After pulling, you may need to:
- Restore your `.env` file from stash if you stashed it
- Merge any local changes to `docker-compose.yml` if needed

### Step 7: Stop Running Containers

```bash
# Stop all containers gracefully
docker compose down

# Verify containers are stopped
docker compose ps
```

### Step 8: Rebuild Docker Images

```bash
# Rebuild images with latest code
docker compose build --no-cache

# This will take several minutes as it:
# - Downloads updated base images
# - Installs PHP dependencies
# - Builds Vue.js frontend
# - Compiles all assets
```

**Note:** The `--no-cache` flag ensures a fresh build. For faster updates, you can omit it:
```bash
docker compose build
```

### Step 9: Start Containers

```bash
# Start all services
docker compose up -d

# Verify containers are starting
docker compose ps
```

### Step 10: Wait for Services to Be Ready

```bash
# Wait for MySQL to be ready (may take 30-60 seconds)
echo "Waiting for MySQL to be ready..."
timeout=60
while ! docker compose exec mysql mysqladmin ping -h localhost --silent; do
    sleep 2
    timeout=$((timeout - 2))
    if [ $timeout -le 0 ]; then
        echo "❌ MySQL failed to start"
        exit 1
    fi
done
echo "✅ MySQL is ready"

# Wait for application to be ready
echo "Waiting for application to be ready..."
timeout=120
while ! curl -f http://localhost:8080/ > /dev/null 2>&1; do
    sleep 5
    timeout=$((timeout - 5))
    if [ $timeout -le 0 ]; then
        echo "❌ Application failed to start"
        exit 1
    fi
done
echo "✅ Application is ready"
```

### Step 11: Verify Everything is Working

```bash
# Check container status
docker compose ps

# Check application logs for errors
docker compose logs orangehrm --tail=50

# Check MySQL logs
docker compose logs mysql --tail=20

# Test application access
curl -I http://localhost:8080

# Verify database connection
docker compose exec mysql mysqladmin ping -h localhost
```

### Step 12: Run Database Migrations (if needed)

```bash
# OrangeHRM handles migrations automatically, but you can verify:
docker compose exec orangehrm php bin/console doctrine:migrations:status

# If migrations are pending, they will run automatically on first request
```

### Step 13: Clear Cache (if needed)

```bash
# Clear application cache
docker compose exec orangehrm rm -rf /var/www/html/src/cache/*

# Restart application container
docker compose restart orangehrm
```

---

## 🔄 Quick Update Script (All-in-One)

Save this as `update-production.sh`:

```bash
#!/bin/bash
set -e

echo "🚀 Starting OrangeHRM Production Update"
echo "========================================"

# Navigate to app directory
cd /opt/orangehrm || { echo "❌ Directory not found"; exit 1; }

# Create backup
echo ""
echo "📦 Creating backup..."
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR" || {
    BACKUP_DIR="$HOME/orangehrm_backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
}
DB_PASSWORD=$(grep "^MYSQL_PASSWORD" .env | cut -d '=' -f2 | tr -d ' ' | tr -d '"')
docker compose exec mysql mysqldump -u orangehrm -p"$DB_PASSWORD" orangehrm_mysql > "$BACKUP_DIR/database.sql"
if [ -f "$BACKUP_DIR/database.sql" ]; then
    echo "✅ Backup created: $BACKUP_DIR/database.sql"
else
    echo "❌ Backup failed!"
    exit 1
fi

# Pull latest changes
echo ""
echo "📥 Pulling latest changes..."
git pull origin main

# Stop containers
echo ""
echo "🛑 Stopping containers..."
docker compose down

# Rebuild
echo ""
echo "🔨 Rebuilding images..."
docker compose build --no-cache

# Start containers
echo ""
echo "▶️  Starting containers..."
docker compose up -d

# Wait for services
echo ""
echo "⏳ Waiting for services to be ready..."
sleep 30

# Verify
echo ""
echo "✅ Verifying services..."
docker compose ps

echo ""
echo "🎉 Update complete!"
echo "Check logs with: docker compose logs -f"
```

Make it executable:
```bash
chmod +x update-production.sh
```

Run it:
```bash
./update-production.sh
```

---

## 🔍 Verification Checklist

After update, verify:

- [ ] All containers are running: `docker compose ps`
- [ ] Application is accessible: Visit your domain/URL
- [ ] Can log in with admin credentials
- [ ] Database connection works
- [ ] No errors in logs: `docker compose logs`
- [ ] Employee data is intact
- [ ] File uploads work
- [ ] Reports generate correctly

---

## 🚨 Troubleshooting

### Issue: Containers won't start

```bash
# Check logs
docker compose logs

# Check for port conflicts
netstat -tulpn | grep -E '8080|3306'

# Restart Docker daemon (if needed)
sudo systemctl restart docker
```

### Issue: Database connection errors

```bash
# Check MySQL is running
docker compose ps mysql

# Check MySQL logs
docker compose logs mysql

# Test connection
docker compose exec mysql mysqladmin ping -h localhost
```

### Issue: Application shows errors

```bash
# Check application logs
docker compose logs orangehrm -f

# Clear cache
docker compose exec orangehrm rm -rf /var/www/html/src/cache/*

# Restart
docker compose restart orangehrm
```

### Issue: Build fails

```bash
# Check Docker has enough space
df -h

# Clean up Docker
docker system prune -a

# Try building again
docker compose build --no-cache
```

---

## 🔙 Rollback Procedure

If something goes wrong, rollback immediately:

### Quick Rollback (if containers are running)

```bash
# Stop containers
docker compose down

# Restore from backup
cd /opt/orangehrm
git checkout <previous-commit-hash>

# Rebuild with previous version
docker compose build
docker compose up -d
```

### Full Rollback (with database restore)

```bash
# Stop containers
docker compose down

# Restore previous code
cd /opt/orangehrm
git checkout <previous-commit-hash>

# Restore database from backup
docker compose up -d mysql
sleep 10
docker compose exec -T mysql mysql -u orangehrm -p$(grep MYSQL_PASSWORD .env | cut -d '=' -f2) orangehrm_mysql < backups/YYYYMMDD_HHMMSS/database.sql

# Restore configuration
cp backups/YYYYMMDD_HHMMSS/Conf.php lib/confs/Conf.php

# Rebuild and start
docker compose build
docker compose up -d
```

---

## 📊 Post-Update Tasks

1. **Monitor logs** for the first hour:
   ```bash
   docker compose logs -f
   ```

2. **Check system resources**:
   ```bash
   docker stats
   ```

3. **Verify backups** are working:
   ```bash
   ls -lh backups/
   ```

4. **Update documentation** if configuration changed

5. **Notify team** that update is complete

---

## 🔐 Security Reminders

After updating:

- [ ] Verify `.env` file is not in git (check `.gitignore`)
- [ ] Ensure all passwords are strong
- [ ] Check firewall rules are still active
- [ ] Verify SSL certificates are valid
- [ ] Review access logs for suspicious activity

---

## 📞 Support

If you encounter issues:

1. Check logs: `docker compose logs -f`
2. Review this guide's troubleshooting section
3. Check GitHub issues: https://github.com/nlangidrik/orangehrm/issues
4. Restore from backup if critical

---

## ✅ Update Complete!

Your production server is now updated with the latest changes from the main branch.

**Next update:** Simply repeat steps 4-10 when new changes are merged to main.

