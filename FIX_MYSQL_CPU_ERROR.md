# Fix MySQL CPU Compatibility Error

## Problem

```
Fatal glibc error: CPU does not support x86-64-v2
```

This error occurs because newer MySQL Docker images require a CPU that supports the x86-64-v2 instruction set. Older servers (especially those with older CPUs) don't support this.

## Solution

Use an older MySQL image version that's compatible with older CPUs. The MySQL 8.0.35 image should work, but if it doesn't, try these alternatives:

### Option 1: Use MySQL 8.0.35 (Recommended - Already Applied)

The docker-compose.yml has been updated to use `mysql:8.0.35` which should work on older CPUs.

### Option 2: Use MySQL 8.0.33 or Earlier

If 8.0.35 still doesn't work, try an earlier version:

```yaml
mysql:
  image: mysql:8.0.33
  # ... rest of config
```

### Option 3: Use MariaDB (Most Compatible)

MariaDB is more compatible with older hardware:

```yaml
mysql:
  image: mariadb:10.11
  container_name: orangehrm_mysql
  # ... rest of config stays the same
  command: --default-authentication-plugin=mysql_native_password --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
```

### Option 4: Use MySQL 5.7 (Last Resort)

If nothing else works, MySQL 5.7 is very compatible but older:

```yaml
mysql:
  image: mysql:5.7
  container_name: orangehrm_mysql
  # ... rest of config
```

**Note:** MySQL 5.7 is end-of-life, so only use if absolutely necessary.

## Steps to Fix

1. **Stop containers:**
   ```bash
   docker compose down
   ```

2. **Update docker-compose.yml** (already done if you pulled latest)

3. **Remove old MySQL image:**
   ```bash
   docker rmi mysql:8.0
   ```

4. **Start containers:**
   ```bash
   docker compose up -d
   ```

5. **Check MySQL logs:**
   ```bash
   docker compose logs mysql --tail=20
   ```

   You should see MySQL starting successfully instead of the glibc error.

## Verify Fix

```bash
# Check MySQL is running
docker compose ps mysql

# Check MySQL logs (should show normal startup, not glibc errors)
docker compose logs mysql --tail=30

# Test MySQL connection
docker compose exec mysql mysqladmin ping -h localhost
```

## If Still Having Issues

1. **Check your CPU:**
   ```bash
   lscpu | grep -i flags
   ```

2. **Try MariaDB instead:**
   - Update docker-compose.yml to use `mariadb:10.11`
   - MariaDB is generally more compatible with older hardware

3. **Check Docker version:**
   ```bash
   docker --version
   docker compose version
   ```

## Migration Notes

If you switch from MySQL to MariaDB:
- Data format is compatible
- No code changes needed
- Just change the image in docker-compose.yml
- Your existing database will work

If you downgrade MySQL versions:
- Make sure to backup first
- MySQL 8.0 data is compatible with 8.0.x versions
- Test thoroughly after downgrade

