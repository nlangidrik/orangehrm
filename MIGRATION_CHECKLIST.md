# 🔧 Migration Checklist - Fix Docker Persistence

Follow these steps to migrate to the new persistent Docker setup.

## Pre-Migration

- [ ] **Read this entire checklist first**
- [ ] **Choose your migration path** (see below)
- [ ] **Backup any critical data** (optional but recommended)

## Choose Your Migration Path

### Path A: Fresh Start (Easiest - Recommended)
**Choose this if:** You haven't completed the wizard yet, or don't have important data

```powershell
# 1. Stop and remove everything
docker compose down -v

# 2. Start fresh with new setup
docker compose up -d --build

# 3. Complete the setup wizard at http://localhost:8080
# (This will be the ONLY time you need to do this!)

# 4. Test persistence
docker compose down
docker compose up -d

# 5. Verify - should NOT see wizard again!
```

- [ ] Removed old containers and volumes
- [ ] Built new containers
- [ ] Completed setup wizard
- [ ] Tested rebuild without data loss

### Path B: Keep Existing Data
**Choose this if:** You have important data and want to keep it

```powershell
# 1. Backup your database first
docker exec orangehrm_mysql mysqldump -u orangehrm -porangehrm123 orangehrm_mysql > backup.sql

# 2. Stop containers (keep volumes)
docker compose down

# 3. Start with new configuration
docker compose up -d --build

# 4. If wizard appears, complete it then restore:
docker exec -i orangehrm_mysql mysql -u orangehrm -porangehrm123 orangehrm_mysql < backup.sql

# 5. Test persistence
docker compose down
docker compose up -d
```

- [ ] Created database backup
- [ ] Stopped containers
- [ ] Rebuilt with new config
- [ ] Completed setup if needed
- [ ] Restored data if needed
- [ ] Tested rebuild without data loss

### Path C: Using Helper Script (Easiest)
**Choose this if:** You want the automated way

```powershell
# 1. Backup first
.\docker-helper.ps1 backup mybackup.sql

# 2. Reset everything
.\docker-helper.ps1 reset
# Type 'yes' when prompted

# 3. Start fresh
.\docker-helper.ps1 start

# 4. Complete wizard at http://localhost:8080

# 5. Test it works
.\docker-helper.ps1 rebuild
```

- [ ] Created backup
- [ ] Reset containers
- [ ] Started fresh
- [ ] Completed wizard
- [ ] Tested with helper script

## Post-Migration Verification

### Verify Volumes Exist
```powershell
docker volume ls | findstr orangehrm
```

You should see:
- [ ] `orangehrm_mysql_data`
- [ ] `orangehrm_orangehrm_config`
- [ ] `orangehrm_orangehrm_cache`
- [ ] `orangehrm_orangehrm_log`
- [ ] `orangehrm_orangehrm_data`
- [ ] `orangehrm_redis_data`

### Verify Configuration Persists
```powershell
# Check if Conf.php exists
docker exec orangehrm_app ls -la /var/www/html/src/config/Conf.php
```

- [ ] Conf.php exists in the container

### Test Full Cycle
```powershell
# 1. Stop containers
docker compose down

# 2. Rebuild everything
docker compose up -d --build

# 3. Access application
# Visit http://localhost:8080
```

- [ ] No setup wizard appears
- [ ] Application works normally
- [ ] Can log in with your credentials
- [ ] No database errors

### Verify Database Data
```powershell
# Connect to database
docker exec -it orangehrm_mysql mysql -u orangehrm -porangehrm123 orangehrm_mysql

# Check tables exist
SHOW TABLES;

# Exit
exit
```

- [ ] Database tables exist
- [ ] Can connect to database
- [ ] Data is present

## Common Issues & Fixes

### Issue: Still seeing setup wizard

**Cause:** Configuration file not persisted

**Fix:**
```powershell
# Check if config volume exists
docker volume ls | findstr orangehrm_config

# If missing, complete wizard once - it will persist
```

### Issue: Database connection error

**Cause:** Environment variables not set or wrong

**Fix:**
```powershell
# Create .env from example if not exists
cp env.example .env

# Edit .env and verify credentials match:
# MYSQL_DATABASE=orangehrm_mysql
# MYSQL_USER=orangehrm
# MYSQL_PASSWORD=orangehrm123
```

### Issue: Permission errors

**Cause:** Volume permissions

**Fix:**
```powershell
# Rebuild with proper permissions
docker compose down
docker compose up -d --build

# Check logs
docker logs orangehrm_app
```

## Success Criteria

You're done when:
- ✅ Can run `docker compose down` and `docker compose up -d` without losing data
- ✅ Can run `docker compose up -d --build` without seeing wizard again
- ✅ Can log into the application
- ✅ Database data persists
- ✅ No errors in logs

## Useful Commands for Testing

```powershell
# Check container status
docker compose ps

# View app logs
docker logs orangehrm_app -f

# View MySQL logs
docker logs orangehrm_mysql -f

# Check volumes
docker volume ls

# Inspect a volume
docker volume inspect orangehrm_mysql_data

# Access MySQL
docker exec -it orangehrm_mysql mysql -u orangehrm -porangehrm123

# Access app container
docker exec -it orangehrm_app bash
```

## Rollback (If Needed)

If something goes wrong and you need to go back:

```powershell
# Stop everything
docker compose down -v

# The old docker-compose files are updated
# If you kept a backup of old files, restore them
# Otherwise, contact support or review Git history
```

## Next Steps After Migration

1. ✅ Test the application thoroughly
2. ✅ Create regular backups: `.\docker-helper.ps1 backup`
3. ✅ Document your setup wizard choices (database name, admin password, etc.)
4. ✅ Set up automated backups if needed
5. ✅ Enjoy never having to run the wizard again! 🎉

## Need Help?

- 📖 Read `QUICK_FIX_SUMMARY.md` for overview
- 📖 Read `DOCKER_PERSISTENCE_GUIDE.md` for detailed guide
- 🔧 Use `.\docker-helper.ps1` for easier management
- 📝 Check Docker logs: `docker logs orangehrm_app`

## Migration Complete! 

Once all checkboxes above are checked, you're done! Your OrangeHRM Docker setup now properly persists data across rebuilds.

