#!/bin/bash

# Start script for OrangeHRM Docker container

set -e

echo "Starting OrangeHRM..."

# Wait for database to be ready
echo "Waiting for database to be ready..."
while ! mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" --silent; do
    echo "Database is unavailable - sleeping"
    sleep 2
done

echo "Database is ready!"

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
chmod -R 775 /var/www/html/src/cache /var/www/html/src/log /var/www/html/src/config

# Create necessary directories if they don't exist
mkdir -p /var/www/html/src/cache
mkdir -p /var/www/html/src/log
mkdir -p /var/www/html/src/config

# Check if OrangeHRM is already installed
if [ ! -f "/var/www/html/src/config/Conf.php" ]; then
    echo "OrangeHRM not installed, running installation..."
    
    # Run CLI installation
    cd /var/www/html/installer
    php cli_install.php --config=cli_install_config.yaml
else
    echo "OrangeHRM already installed, skipping installation..."
fi

# Start supervisor
echo "Starting supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
