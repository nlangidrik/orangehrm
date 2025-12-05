#!/bin/bash
# Script to fix the hs_hr_config table column issue
# Run this from your server

echo "Checking hs_hr_config table structure..."

# Check current table structure
docker exec orangehrm_mysql mysql -u root -prootpassword orangehrm_mysql -e "DESCRIBE hs_hr_config;" 2>/dev/null

echo ""
echo "Checking if 'key' column exists..."
KEY_EXISTS=$(docker exec orangehrm_mysql mysql -u root -prootpassword orangehrm_mysql -e "SHOW COLUMNS FROM hs_hr_config LIKE 'key';" 2>/dev/null | grep -c "key" || echo "0")

echo ""
echo "Checking if 'name' column exists..."
NAME_EXISTS=$(docker exec orangehrm_mysql mysql -u root -prootpassword orangehrm_mysql -e "SHOW COLUMNS FROM hs_hr_config LIKE 'name';" 2>/dev/null | grep -c "name" || echo "0")

echo ""
if [ "$KEY_EXISTS" -gt 0 ] && [ "$NAME_EXISTS" -eq 0 ]; then
    echo "Column 'key' exists but 'name' doesn't. Renaming column..."
    docker exec orangehrm_mysql mysql -u root -prootpassword orangehrm_mysql -e "ALTER TABLE hs_hr_config CHANGE \`key\` name VARCHAR(100) NOT NULL DEFAULT '';" 2>/dev/null
    echo "✅ Column renamed successfully!"
elif [ "$NAME_EXISTS" -gt 0 ]; then
    echo "✅ Column 'name' already exists. Migration should proceed."
else
    echo "⚠️  Neither 'key' nor 'name' column found. This might indicate a different issue."
    echo "Current table structure:"
    docker exec orangehrm_mysql mysql -u root -prootpassword orangehrm_mysql -e "DESCRIBE hs_hr_config;" 2>/dev/null
fi

echo ""
echo "Verifying table structure after fix:"
docker exec orangehrm_mysql mysql -u root -prootpassword orangehrm_mysql -e "DESCRIBE hs_hr_config;" 2>/dev/null

