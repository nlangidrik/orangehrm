#!/bin/bash

# Health check script for OrangeHRM

# Check if Apache is running
if ! pgrep apache2 > /dev/null; then
    echo "Apache2 is not running"
    exit 1
fi

# Check if OrangeHRM is accessible
if ! curl -f http://localhost/ > /dev/null 2>&1; then
    echo "OrangeHRM is not accessible"
    exit 1
fi

# Check if database connection is working
if [ -f "/var/www/html/src/config/Conf.php" ]; then
    # Try to connect to database
    if ! mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" --silent; then
        echo "Database connection failed"
        exit 1
    fi
fi

echo "Health check passed"
exit 0
