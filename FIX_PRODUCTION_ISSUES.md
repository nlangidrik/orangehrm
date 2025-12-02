# Quick Fix for Production Update Issues

## Issue 1: Permission Denied Creating Backup Directory

**Problem:** `mkdir: cannot create directory 'backups/...': Permission denied`

**Solution:**

```bash
# Option 1: Create backup in your home directory
BACKUP_DIR="$HOME/orangehrm_backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Option 2: Fix permissions on backups directory
sudo mkdir -p backups
sudo chown -R $USER:$USER backups

# Option 3: Use current directory
BACKUP_DIR="./backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
```

## Issue 2: Uncommitted Changes to .env and docker-compose.yml

**Problem:** Git shows modified files before update

**Solution - Stash your local changes (Recommended):**

```bash
# Stash your local production config
git stash push -m "Production config before update"

# Now pull updates
git pull origin main

# After update, restore your config
git stash pop
```

**Alternative - Commit your changes:**

```bash
# If your local changes are important, commit them first
git add .env docker-compose.yml
git commit -m "Production server configuration"

# Then pull (you may need to merge)
git pull origin main
```

## Issue 3: docker-compose.yml Version Warning

**Problem:** `WARN[0000] the attribute 'version' is obsolete`

**Solution:**

The `version` line has been removed in the latest docker-compose.yml. After pulling:

```bash
# Check if version line exists
grep "^version:" docker-compose.yml

# If it exists, remove it (it's on line 1 or 2)
sed -i '/^version:/d' docker-compose.yml

# Or manually edit and remove the line:
# version: '3.8'
```

## Issue 4: Nginx Container Restarting

**Problem:** `orangehrm_nginx   Restarting (1) 47 seconds ago`

**Solution:**

Since we removed nginx from docker-compose.yml, you need to remove the old container:

```bash
# Stop and remove the nginx container
docker compose stop nginx
docker compose rm -f nginx

# Or if using old docker-compose file
docker stop orangehrm_nginx
docker rm orangehrm_nginx
```

## Complete Fix Script

Run this to fix all issues at once:

```bash
#!/bin/bash
set -e

echo "🔧 Fixing Production Update Issues"
echo "=================================="

# 1. Fix backup directory permissions
echo ""
echo "1. Fixing backup directory..."
sudo mkdir -p backups 2>/dev/null || mkdir -p "$HOME/orangehrm_backups"
sudo chown -R $USER:$USER backups 2>/dev/null || true

# 2. Stash local changes
echo ""
echo "2. Stashing local changes..."
git stash push -m "Production config $(date +%Y%m%d_%H%M%S)" || echo "No changes to stash"

# 3. Remove version from docker-compose.yml if exists
echo ""
echo "3. Fixing docker-compose.yml..."
if grep -q "^version:" docker-compose.yml; then
    sed -i '/^version:/d' docker-compose.yml
    echo "✅ Removed obsolete version attribute"
fi

# 4. Remove old nginx container
echo ""
echo "4. Removing old nginx container..."
docker stop orangehrm_nginx 2>/dev/null || true
docker rm orangehrm_nginx 2>/dev/null || true
echo "✅ Nginx container removed"

# 5. Pull latest changes
echo ""
echo "5. Pulling latest changes..."
git pull origin main

# 6. Restore stashed config
echo ""
echo "6. Restoring your configuration..."
git stash pop 2>/dev/null || echo "No stashed changes to restore"

echo ""
echo "✅ All fixes applied!"
echo ""
echo "Next steps:"
echo "  1. Review your .env file (restored from stash)"
echo "  2. Review docker-compose.yml changes"
echo "  3. Continue with backup and update process"
```

Save as `fix-issues.sh`, make executable, and run:
```bash
chmod +x fix-issues.sh
./fix-issues.sh
```

## Quick Commands for Your Current Situation

Based on your output, run these commands:

```bash
# 1. Fix backup directory
sudo mkdir -p backups
sudo chown -R $USER:$USER backups

# 2. Stash your local changes
git stash push -m "Production config before update"

# 3. Remove old nginx container
docker compose stop nginx
docker compose rm -f nginx

# 4. Remove version line from docker-compose.yml (if still there after pull)
sed -i '/^version:/d' docker-compose.yml

# 5. Now continue with the update process
git pull origin main
git stash pop  # Restore your .env file

# 6. Continue with backup and rebuild
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
DB_PASSWORD=$(grep "^MYSQL_PASSWORD" .env | cut -d '=' -f2 | tr -d ' ' | tr -d '"')
docker compose exec mysql mysqldump -u orangehrm -p"$DB_PASSWORD" orangehrm_mysql > "$BACKUP_DIR/database.sql"
```

