# Docker Persistence Guide - OrangeHRM

## What Was Fixed

Your OrangeHRM installation was losing its configuration every time you rebuilt the containers because:

1. The entire application directory (`/var/www/html`) was mounted as a Docker volume
2. This caused the installation configuration file (`Conf.php`) to be lost on rebuild
3. The setup wizard would run again because the app couldn't find its configuration

## What Changed

The Docker Compose files have been updated to persist **only** the data that needs to survive rebuilds:

✅ **Database** - MySQL data in `mysql_data` volume (already working)
✅ **Configuration** - Installation settings in `orangehrm_config` volume
✅ **Cache** - Application cache in `orangehrm_cache` volume  
✅ **Logs** - Application logs in `orangehrm_log` volume
✅ **User Data** - Uploaded files and user data in `orangehrm_data` volume

## How to Migrate from Old Setup

### Option 1: Fresh Start (Recommended if you haven't done the wizard yet)

```bash
# Stop and remove old containers and volumes
docker compose down -v

# Start fresh with the new setup
docker compose up -d --build

# Complete the setup wizard ONE TIME
# Your data will now persist!
```

### Option 2: Keep Existing Data

If you've already completed the setup wizard and have data:

```bash
# Stop containers but DON'T remove volumes
docker compose down

# Rebuild and start with new configuration
docker compose up -d --build

# Your database data is safe in the mysql_data volume
# The config will be recreated on first access
```

### Option 3: Backup First (Safest)

```bash
# Create a database backup
docker exec orangehrm_mysql mysqldump -u orangehrm -porangehrm123 orangehrm_mysql > backup.sql

# Stop and remove everything
docker compose down -v

# Start fresh
docker compose up -d --build

# Complete the wizard, then restore your data if needed
docker exec -i orangehrm_mysql mysql -u orangehrm -porangehrm123 orangehrm_mysql < backup.sql
```

## Normal Usage Now

After you complete the setup wizard **once**, you can safely:

```bash
# Stop containers (data persists)
docker compose down

# Rebuild and start (no wizard needed!)
docker compose up -d --build

# Update code, rebuild, restart - your data stays!
docker compose down
docker compose up -d --build
```

## Important Commands

### Check Volume Status
```bash
# See all volumes
docker volume ls | findstr orangehrm

# Inspect a specific volume
docker volume inspect orangehrm_mysql_data
docker volume inspect orangehrm_orangehrm_config
```

### Clean Start (Remove Everything)
```bash
# Remove containers and ALL volumes
docker compose down -v

# Remove individual volumes if needed
docker volume rm orangehrm_mysql_data
docker volume rm orangehrm_orangehrm_config
docker volume rm orangehrm_orangehrm_cache
docker volume rm orangehrm_orangehrm_log
docker volume rm orangehrm_orangehrm_data
```

### View Logs
```bash
# View app logs
docker logs orangehrm_app -f

# View MySQL logs
docker logs orangehrm_mysql -f
```

### Access the Database
```bash
# Connect to MySQL
docker exec -it orangehrm_mysql mysql -u orangehrm -porangehrm123 orangehrm_mysql

# Show databases
docker exec -it orangehrm_mysql mysql -u root -prootpassword -e "SHOW DATABASES;"
```

## Troubleshooting

### Still Seeing the Setup Wizard?

1. Check if the config volume exists:
   ```bash
   docker volume ls | findstr orangehrm_config
   ```

2. Check if Conf.php exists in the volume:
   ```bash
   docker exec orangehrm_app ls -la /var/www/html/src/config/
   ```

3. If missing, complete the wizard once - it will create the file

### Database Connection Errors?

Make sure your environment variables match in `.env`:
```env
MYSQL_DATABASE=orangehrm_mysql
MYSQL_USER=orangehrm
MYSQL_PASSWORD=orangehrm123
MYSQL_ROOT_PASSWORD=rootpassword
```

### Need to Reset Everything?

```bash
# Nuclear option - removes everything
docker compose down -v
docker system prune -a --volumes
docker compose up -d --build
```

## File Locations

- **Database**: Stored in Docker volume `mysql_data`
- **Config**: Stored in Docker volume `orangehrm_config`
- **Cache**: Stored in Docker volume `orangehrm_cache`
- **Logs**: Stored in Docker volume `orangehrm_log`
- **Uploads**: Stored in Docker volume `orangehrm_data`

## Benefits of This Setup

✅ Complete the wizard only once
✅ Database persists across rebuilds
✅ Configuration persists across rebuilds
✅ Can rebuild containers without losing data
✅ Can update code without losing data
✅ Faster container starts (no re-installation)
✅ Proper separation of code and data

## Next Steps

1. Choose your migration option above
2. Complete the setup wizard once
3. Test by running `docker compose down` then `docker compose up -d`
4. Verify you don't see the wizard again
5. Enjoy persistent data! 🎉

