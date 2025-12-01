#!/bin/bash
# OrangeHRM Complete Backup Script (Linux/Bash)
# This script creates a backup of the database AND file uploads (employee photos)

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/orangehrm_backup_$TIMESTAMP.sql"
PHOTOS_BACKUP_FILE="$BACKUP_DIR/orangehrm_photos_$TIMESTAMP.tar.gz"

# Create backups directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "Created backups directory: $BACKUP_DIR"
fi

echo "Starting complete backup (database + file uploads)..."
echo "Backup files:"
echo "  Database: $BACKUP_FILE"
echo "  Photos: $PHOTOS_BACKUP_FILE"

# Backup database
echo ""
echo "Backing up database..."
docker exec orangehrm_mysql mysqldump -uorangehrm -porangehrm123 --no-tablespaces orangehrm_mysql > "$BACKUP_FILE"

if [ $? -ne 0 ]; then
    echo ""
    echo "Database backup failed! Please check the error messages above."
    exit 1
fi

# Backup employee photos
echo "Backing up employee photos..."
docker exec orangehrm_app bash -c "cd /var/www/html/src/plugins/orangehrmPimPlugin/public/webroot && tar -czf - photos 2>/dev/null" > "$PHOTOS_BACKUP_FILE"

if [ $? -ne 0 ]; then
    echo "Warning: Could not backup employee photos. They may not exist yet."
    rm -f "$PHOTOS_BACKUP_FILE"
    PHOTOS_BACKUP_FILE=""
fi

# Summary
DB_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo ""
echo "Backup completed successfully!"
echo "Database backup: $BACKUP_FILE ($DB_SIZE)"
if [ -n "$PHOTOS_BACKUP_FILE" ] && [ -f "$PHOTOS_BACKUP_FILE" ]; then
    PHOTOS_SIZE=$(du -h "$PHOTOS_BACKUP_FILE" | cut -f1)
    echo "Photos backup: $PHOTOS_BACKUP_FILE ($PHOTOS_SIZE)"
fi
echo ""
echo "To restore this backup, run:"
echo "./restore-database.sh $BACKUP_FILE"

