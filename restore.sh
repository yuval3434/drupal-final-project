#!/bin/bash
set -e
echo "Starting restore process..."

echo "Restoring the PostgreSQL database..."
cat drupal_db_backup.sql | docker exec -i drupal-db psql -U root -d drupal

echo "Restoring the Drupal sites folder from tar.gz..."
cat sites_backup.tar.gz | docker exec -i drupal-app tar -xzf - -C /var/www/html

echo "Restore completed successfully!"


