#!/bin/bash
# OrangeHRM Complete Restore Script (Linux/Bash)
# This script restores a database backup AND file uploads (employee photos)

if [ -z "$1" ]; then
    echo "Usage: $0 <backup-file> [photos-backup-file]"
    echo "Example: $0 ./backups/orangehrm_backup_20251201_214335.sql"
    echo "         $0 ./backups/orangehrm_backup_20251201_214335.sql ./backups/orangehrm_photos_20251201_214335.tar.gz"
    exit 1
fi

BACKUP_FILE="$1"
PHOTOS_BACKUP_FILE="$2"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Try to find matching photos backup if not provided
if [ -z "$PHOTOS_BACKUP_FILE" ]; then
    BACKUP_BASENAME=$(basename "$BACKUP_FILE" .sql)
    BACKUP_DIR=$(dirname "$BACKUP_FILE")
    TIMESTAMP=$(echo "$BACKUP_BASENAME" | sed 's/orangehrm_backup_//')
    POSSIBLE_PHOTOS_FILE="$BACKUP_DIR/orangehrm_photos_$TIMESTAMP.tar.gz"
    if [ -f "$POSSIBLE_PHOTOS_FILE" ]; then
        PHOTOS_BACKUP_FILE="$POSSIBLE_PHOTOS_FILE"
        echo "Found matching photos backup: $PHOTOS_BACKUP_FILE"
    fi
fi

echo "WARNING: This will overwrite your current database and file uploads!"
read -p "Press Enter to continue or Ctrl+C to cancel..."

echo ""
echo "Starting restore..."
echo "Database backup: $BACKUP_FILE"
if [ -n "$PHOTOS_BACKUP_FILE" ]; then
    echo "Photos backup: $PHOTOS_BACKUP_FILE"
else
    echo "Photos backup: Not found (will skip)"
fi

# Create a temporary backup before restoring
TEMP_BACKUP="./backups/pre_restore_backup_$(date +%Y%m%d_%H%M%S).sql"
echo ""
echo "Creating safety backup before restore..."
docker exec orangehrm_mysql mysqldump -uorangehrm -porangehrm123 --no-tablespaces orangehrm_mysql > "$TEMP_BACKUP"

if [ $? -eq 0 ]; then
    echo "Safety backup created: $TEMP_BACKUP"
else
    echo "Warning: Could not create safety backup. Continuing anyway..."
fi

# Restore the database
echo ""
echo "Restoring database..."
cat "$BACKUP_FILE" | docker exec -i orangehrm_mysql mysql -uorangehrm -porangehrm123 orangehrm_mysql

if [ $? -ne 0 ]; then
    echo ""
    echo "Database restore failed! Please check the error messages above."
    echo "You can restore the safety backup if needed."
    exit 1
fi

# Restore employee photos if backup exists
if [ -n "$PHOTOS_BACKUP_FILE" ] && [ -f "$PHOTOS_BACKUP_FILE" ]; then
    echo ""
    echo "Restoring employee photos..."
    cat "$PHOTOS_BACKUP_FILE" | docker exec -i orangehrm_app bash -c "cd /var/www/html/src/plugins/orangehrmPimPlugin/public/webroot && tar -xzf - 2>/dev/null && chown -R www-data:www-data photos 2>/dev/null || true"
    
    if [ $? -eq 0 ]; then
        echo "Employee photos restored successfully!"
    else
        echo "Warning: Could not restore employee photos. They may not exist in the backup."
    fi
fi

echo ""
echo "Restore completed successfully!"

