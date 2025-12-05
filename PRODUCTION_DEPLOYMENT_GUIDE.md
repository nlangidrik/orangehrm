# Production Deployment Guide - Migration Column Fix

## Quick Answer

**When you pull the fix on production:**
- ✅ The **code fix is automatic** - the migration will now check before renaming
- ⚠️ You **may need to fix the database once** if it's in an inconsistent state
- ✅ After that, the code handles everything automatically

## Deployment Steps

### Step 1: Pull the Latest Code

```bash
# On your production server
cd /opt/orangehrm  # or wherever your code is
git fetch origin
git checkout fix/migration-column-key-error
# OR merge it into your main branch first, then:
# git checkout main
# git merge fix/migration-column-key-error
```

### Step 2: Check Database State (One-Time Check)

Before running the migration, check if your database needs fixing:

```bash
# Check current table structure
docker exec orangehrm_mysql mysql -u root -prootpassword orangehrm_mysql -e "DESCRIBE hs_hr_config;"
```

**Possible outcomes:**

#### Outcome A: Table has `key` column (needs rename)
```sql
Field | Type
------|------
key   | varchar(100)
value | varchar(512)
```

**Action:** Run the fix once:
```bash
docker exec orangehrm_mysql mysql -u root -prootpassword orangehrm_mysql -e "ALTER TABLE hs_hr_config CHANGE \`key\` name VARCHAR(100) NOT NULL DEFAULT '';"
```

#### Outcome B: Table has `name` column (already fixed)
```sql
Field | Type
------|------
name  | varchar(100)
value | varchar(512)
```

**Action:** ✅ Nothing needed! The code fix will skip the rename automatically.

#### Outcome C: Table doesn't exist (fresh install)
**Action:** ✅ Nothing needed! The migration will create it with the correct structure.

### Step 3: Run the Migration

After pulling the code and fixing the database (if needed), run the installation/migration:

```bash
# If using web installer, just refresh and continue
# If using CLI:
docker exec orangehrm_app php installer/console install:on-new-database
# OR
docker exec orangehrm_app php installer/console upgrade
```

### Step 4: Verify Success

```bash
# Check the installer log
docker exec orangehrm_app tail -n 50 /var/www/html/src/log/installer.log

# Verify table structure
docker exec orangehrm_mysql mysql -u root -prootpassword orangehrm_mysql -e "DESCRIBE hs_hr_config;"
```

Should show `name` column (not `key`).

## Automated One-Line Fix Script

If you want to automate the database check and fix:

```bash
# Copy the fix script to production
scp fix_migration_column_issue.sh user@production-server:/opt/orangehrm/

# On production server
chmod +x fix_migration_column_issue.sh
./fix_migration_column_issue.sh
```

## What the Code Fix Does

The updated migration code (`installer/Migration/V5_0_0_beta/Migration.php`) now:

1. **Checks if `key` column exists** before trying to rename
2. **Checks if `name` column already exists** (already renamed)
3. **Only renames if needed** - prevents errors
4. **Handles all edge cases** automatically

```php
// Before (would fail if column doesn't exist):
$this->getSchemaHelper()->renameColumn('hs_hr_config', '`key`', 'name');

// After (checks first):
if ($this->getSchemaHelper()->columnExists('hs_hr_config', 'key') && 
    !$this->getSchemaHelper()->columnExists('hs_hr_config', 'name')) {
    $this->getSchemaHelper()->renameColumn('hs_hr_config', '`key`', 'name');
}
```

## Summary

| Scenario | Code Fix | Database Fix Needed? |
|----------|----------|---------------------|
| Fresh installation | ✅ Handles it | ❌ No |
| Database has `key` column | ✅ Will rename | ⚠️ Yes, once |
| Database has `name` column | ✅ Skips rename | ❌ No |
| Database in inconsistent state | ✅ Prevents errors | ⚠️ Maybe, check first |

## Best Practice

1. **Pull the code fix** (always do this)
2. **Check database state** (one-time, if migration previously failed)
3. **Fix database if needed** (one-time SQL command)
4. **Run migration** (code handles everything from here)

The code fix ensures this won't happen again, but you may need to fix the database **once** if it's already in a broken state.

