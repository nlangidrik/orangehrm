# Fix: Column 'key' does not exist in table 'hs_hr_config'

## Problem

The migration from version 4.9 to 5.0 is failing with:
```
Column 'key' does not exist in table 'hs_hr_config'
```

This happens because the migration tries to rename the `key` column to `name`, but the column doesn't exist (likely already renamed in a previous migration attempt).

## Solution

I've fixed the migration code to check if the column exists before trying to rename it. However, you also need to fix the current database state.

### Option 1: Quick Fix - Manually Rename the Column (Recommended)

If the `key` column exists but `name` doesn't, manually rename it:

```bash
# Connect to MySQL and rename the column
docker exec -it orangehrm_mysql mysql -u root -prootpassword orangehrm_mysql

# Then run this SQL:
ALTER TABLE hs_hr_config CHANGE `key` name VARCHAR(100) NOT NULL DEFAULT '';
EXIT;
```

### Option 2: Use the Fix Script

I've created a script that checks and fixes the issue automatically:

```bash
# Make it executable
chmod +x fix_migration_column_issue.sh

# Run it
./fix_migration_column_issue.sh
```

### Option 3: Check Current State and Fix Manually

1. **Check the current table structure:**
   ```bash
   docker exec orangehrm_mysql mysql -u root -prootpassword orangehrm_mysql -e "DESCRIBE hs_hr_config;"
   ```

2. **Check if 'key' column exists:**
   ```bash
   docker exec orangehrm_mysql mysql -u root -prootpassword orangehrm_mysql -e "SHOW COLUMNS FROM hs_hr_config LIKE 'key';"
   ```

3. **Check if 'name' column exists:**
   ```bash
   docker exec orangehrm_mysql mysql -u root -prootpassword orangehrm_mysql -e "SHOW COLUMNS FROM hs_hr_config LIKE 'name';"
   ```

4. **If 'key' exists but 'name' doesn't, rename it:**
   ```bash
   docker exec orangehrm_mysql mysql -u root -prootpassword orangehrm_mysql -e "ALTER TABLE hs_hr_config CHANGE \`key\` name VARCHAR(100) NOT NULL DEFAULT '';"
   ```

5. **If 'name' already exists, the column was already renamed - you can proceed with the installation.**

### Option 4: Clean Start (If Nothing Else Works)

If the database is in an inconsistent state, you can start fresh:

```bash
# WARNING: This deletes all data!
docker compose down
docker volume rm orangehrm-6_mysql_data  # or your volume name
docker compose up -d
sleep 20
```

Then try the installation again.

## Code Fix Applied

I've updated the migration file `installer/Migration/V5_0_0_beta/Migration.php` to check if the column exists before trying to rename it. This prevents the error from occurring in future migration attempts.

The fix checks:
- If `key` column exists AND `name` doesn't exist → rename it
- If `name` already exists → skip (already renamed)
- If neither exists → skip (might be a different table structure issue)

## After Fixing

1. **Restart the installation process:**
   - Go to your installer URL
   - Start from the beginning or continue from where it failed

2. **Monitor the logs:**
   ```bash
   docker exec orangehrm_app tail -f /var/www/html/src/log/installer.log
   ```

3. **Verify the fix worked:**
   ```bash
   docker exec orangehrm_mysql mysql -u root -prootpassword orangehrm_mysql -e "DESCRIBE hs_hr_config;"
   ```
   
   You should see a `name` column (not `key`).

## Expected Result

After fixing, the migration should:
- ✅ Skip the rename if `name` column already exists
- ✅ Rename `key` to `name` if `key` exists and `name` doesn't
- ✅ Continue with the rest of the migration

## Still Having Issues?

If the problem persists:

1. **Check the full table structure:**
   ```bash
   docker exec orangehrm_mysql mysql -u root -prootpassword orangehrm_mysql -e "SHOW CREATE TABLE hs_hr_config\G"
   ```

2. **Check if the table exists:**
   ```bash
   docker exec orangehrm_mysql mysql -u root -prootpassword orangehrm_mysql -e "SHOW TABLES LIKE 'hs_hr_config';"
   ```

3. **Review the installer log for other errors:**
   ```bash
   docker exec orangehrm_app tail -n 100 /var/www/html/src/log/installer.log
   ```

4. **Share the output** if you need further assistance.

