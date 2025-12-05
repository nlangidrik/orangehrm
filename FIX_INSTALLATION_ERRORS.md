# How to Fix Installation Errors

This guide provides step-by-step instructions to fix the 500 error and other issues during OrangeHRM installation.

## Step 1: Check the Installer Log (Docker)

The actual error details are in the installer log. Since you're using Docker, access it like this:

### Option A: View Log from Docker Container

```bash
# View the last 50 lines of the installer log
docker exec orangehrm_app tail -n 50 /var/www/html/src/log/installer.log

# Or view the entire log
docker exec orangehrm_app cat /var/www/html/src/log/installer.log

# Or follow the log in real-time
docker exec orangehrm_app tail -f /var/www/html/src/log/installer.log
```

### Option B: Access Log from Host (if volume is mounted)

```bash
# On Windows PowerShell
Get-Content src\log\installer.log -Tail 50

# Or open the file directly
notepad src\log\installer.log
```

**Look for:**
- Error messages starting with `[ERROR]`
- Stack traces showing the exact failure point
- Database connection errors
- SQL syntax errors
- Permission denied errors

---

## Step 2: Common Fixes Based on Error Type

### Fix 1: Database Connection Issues

**Symptoms:**
- Error code 2002 (Connection refused)
- "Access denied" errors
- "Database not found" errors

**Solution:**

1. **Verify MySQL container is running:**
   ```bash
   docker compose ps
   # Should show mysql container as "Up"
   ```

2. **Check MySQL logs:**
   ```bash
   docker compose logs mysql --tail=50
   ```

3. **Test database connection:**
   ```bash
   # Connect to MySQL container
   docker exec -it orangehrm_mysql mysql -u orangehrm -porangehrm123
   
   # Or test from app container
   docker exec orangehrm_app php -r "new PDO('mysql:host=mysql;port=3306', 'orangehrm', 'orangehrm123');"
   ```

4. **If MySQL isn't running, restart:**
   ```bash
   docker compose restart mysql
   # Wait 10-15 seconds for MySQL to fully start
   sleep 15
   ```

---

### Fix 2: Database Permission Issues

**Symptoms:**
- Error: "Access denied for user"
- Error: "Insufficient privileges"
- Migration fails on CREATE/ALTER statements

**Solution:**

1. **Grant proper permissions to the database user:**

   ```bash
   # Connect to MySQL as root
   docker exec -it orangehrm_mysql mysql -u root -prootpassword
   ```

2. **Run these SQL commands in MySQL:**

   ```sql
   -- Grant all privileges on the database
   GRANT ALL PRIVILEGES ON orangehrm_mysql.* TO 'orangehrm'@'%';
   FLUSH PRIVILEGES;
   
   -- Verify permissions
   SHOW GRANTS FOR 'orangehrm'@'%';
   
   -- Exit
   EXIT;
   ```

3. **If using a new database, ensure it exists:**

   ```sql
   CREATE DATABASE IF NOT EXISTS orangehrm_mysql CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   GRANT ALL PRIVILEGES ON orangehrm_mysql.* TO 'orangehrm'@'%';
   FLUSH PRIVILEGES;
   ```

---

### Fix 3: Migration Timeout or Execution Errors

**Symptoms:**
- Migration hangs at 99%
- "Execution time limit exceeded"
- Specific SQL errors in the log

**Solution:**

1. **Increase PHP execution time (already handled by installer, but verify):**
   - The installer sets `set_time_limit(0)` automatically
   - Check if your PHP configuration allows this

2. **Check for specific SQL errors in the log:**
   ```bash
   docker exec orangehrm_app grep -i "error\|exception\|failed" /var/www/html/src/log/installer.log | tail -20
   ```

3. **Common migration issues:**

   **Issue: Table already exists**
   - If you're re-running installation, drop the database first:
   ```bash
   docker exec -it orangehrm_mysql mysql -u root -prootpassword -e "DROP DATABASE IF EXISTS orangehrm_mysql; CREATE DATABASE orangehrm_mysql CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
   ```

   **Issue: Column already exists**
   - This usually means a previous migration partially completed
   - Drop and recreate the database (see above)

   **Issue: Foreign key constraint errors**
   - The installer should handle this, but if it persists:
   ```sql
   SET FOREIGN_KEY_CHECKS=0;
   -- Let migration run
   SET FOREIGN_KEY_CHECKS=1;
   ```

---

### Fix 4: Database Character Set Issues

**Symptoms:**
- Errors about utf8mb4
- Collation errors

**Solution:**

1. **Ensure database uses correct character set:**

   ```bash
   docker exec -it orangehrm_mysql mysql -u root -prootpassword
   ```

   ```sql
   -- Check current database
   SHOW CREATE DATABASE orangehrm_mysql;
   
   -- Recreate with correct charset if needed
   DROP DATABASE IF EXISTS orangehrm_mysql;
   CREATE DATABASE orangehrm_mysql 
     CHARACTER SET utf8mb4 
     COLLATE utf8mb4_unicode_ci;
   
   GRANT ALL PRIVILEGES ON orangehrm_mysql.* TO 'orangehrm'@'%';
   FLUSH PRIVILEGES;
   EXIT;
   ```

2. **Verify MySQL container configuration:**
   - Your `docker-compose.yml` already has: `--character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci`
   - This is correct!

---

### Fix 5: Clean Installation (Start Fresh)

If nothing else works, start with a clean database:

```bash
# Stop containers
docker compose down

# Remove database volume (WARNING: This deletes all data!)
docker volume rm orangehrm-6_mysql_data

# Or if using named volume:
docker volume rm orangehrm_mysql_data

# Start fresh
docker compose up -d

# Wait for MySQL to be ready
sleep 20

# Verify MySQL is ready
docker compose exec mysql mysqladmin ping -h localhost

# Now try installation again
```

---

## Step 3: Fix the 404 Error for custom-styles.css

This is a non-critical error, but here's how to fix it if you want:

### Option A: Make CSS Reference Conditional (Recommended)

Edit `src/plugins/orangehrmCorePlugin/templates/base.html.twig`:

```twig
{% block links %}{% endblock %}
{% block stylesheets %}{% endblock %}
{% if publicPath is defined %}
  <link href="{{ publicPath }}/custom-styles.css" rel="stylesheet"/>
{% endif %}
```

### Option B: Create Empty CSS File in Installer Path

```bash
# Create empty CSS file (harmless, just prevents 404)
docker exec orangehrm_app touch /var/www/html/installer/custom-styles.css
```

### Option C: Ignore It (Recommended)
- This error doesn't affect installation
- The file is only needed after installation for custom branding
- You can fix it later if needed

---

## Step 4: Browser Extension Error

**"Receiving end does not exist"** - This is NOT an OrangeHRM error.

**Solution:**
- **Ignore it completely** - It's a browser extension issue
- Or disable browser extensions temporarily
- Or use incognito/private browsing mode

---

## Step 5: Complete Troubleshooting Workflow

Run these commands in order to diagnose and fix:

```bash
# 1. Check container status
docker compose ps

# 2. Check MySQL logs
docker compose logs mysql --tail=30

# 3. Check app logs
docker compose logs orangehrm --tail=30

# 4. Check installer log for errors
docker exec orangehrm_app tail -n 100 /var/www/html/src/log/installer.log

# 5. Test database connection
docker exec orangehrm_app php -r "
try {
    \$pdo = new PDO('mysql:host=mysql;port=3306;dbname=orangehrm_mysql', 'orangehrm', 'orangehrm123');
    echo 'Connection successful!\n';
} catch (PDOException \$e) {
    echo 'Connection failed: ' . \$e->getMessage() . '\n';
}
"

# 6. Check database permissions
docker exec -it orangehrm_mysql mysql -u root -prootpassword -e "SHOW GRANTS FOR 'orangehrm'@'%';"

# 7. If needed, fix permissions
docker exec -it orangehrm_mysql mysql -u root -prootpassword <<EOF
GRANT ALL PRIVILEGES ON orangehrm_mysql.* TO 'orangehrm'@'%';
FLUSH PRIVILEGES;
EOF

# 8. Restart containers if needed
docker compose restart
```

---

## Step 6: Alternative - Use CLI Installer

If the web installer continues to fail, use the CLI installer for better error visibility:

```bash
# Access the container
docker exec -it orangehrm_app bash

# Run CLI installer
cd /var/www/html
php installer/cli_install.php

# Or use the console command
php installer/console install:on-new-database
```

The CLI installer will show you the exact error messages in real-time.

---

## Step 7: Check Specific Migration Errors

If the log shows a specific migration version failing:

1. **Note the migration version** (e.g., "5.0", "5.1", etc.)
2. **Check the migration file:**
   ```bash
   # List available migrations
   docker exec orangehrm_app ls -la /var/www/html/installer/Migration/
   
   # View specific migration (replace V5_X_0 with actual version)
   docker exec orangehrm_app cat /var/www/html/installer/Migration/V5_0_0/Migration.php
   ```

3. **Common migration issues:**
   - **Schema conflicts:** Database already has tables/columns
   - **Data type mismatches:** Check MySQL version compatibility
   - **Foreign key issues:** Check if tables exist in correct order

---

## Quick Reference: Most Common Solutions

### If you see "Access denied":
```bash
docker exec -it orangehrm_mysql mysql -u root -prootpassword -e "GRANT ALL PRIVILEGES ON orangehrm_mysql.* TO 'orangehrm'@'%'; FLUSH PRIVILEGES;"
```

### If you see "Table already exists":
```bash
docker exec -it orangehrm_mysql mysql -u root -prootpassword -e "DROP DATABASE orangehrm_mysql; CREATE DATABASE orangehrm_mysql CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

### If you see connection errors:
```bash
docker compose restart mysql
sleep 15
docker compose ps
```

### If migration hangs:
```bash
# Check the log for specific errors
docker exec orangehrm_app tail -f /var/www/html/src/log/installer.log
```

---

## Still Having Issues?

1. **Share the installer log output:**
   ```bash
   docker exec orangehrm_app cat /var/www/html/src/log/installer.log > installer_error.log
   ```

2. **Check these files:**
   - `src/log/installer.log` - Main error log
   - `docker-compose.yml` - Database configuration
   - Database connection settings in installer UI

3. **Verify system requirements:**
   - PHP 7.4-8.1
   - MySQL 5.5-5.7 or MariaDB 5.5-10.7
   - Sufficient disk space
   - Proper file permissions

---

## Success Indicators

✅ Installation is successful when:
- All 6 installation steps complete with green checkmarks
- Progress reaches 100%
- You see "Installation Complete" message
- You can access the login page

❌ Installation failed if:
- Any step shows red error icon
- Progress stops before 100%
- Error message displayed
- Cannot access login page

