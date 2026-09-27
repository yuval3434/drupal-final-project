#!/bin/bash
echo "Starting restore process..."

echo "Restoring the PostgreSQL database..."
cat drupal_db_backup.sql | docker exec -i drupal-db psql -U root -d drupal

echo "Restoring the Drupal sites folder..."
docker cp ./sites_backup/. drupal-app:/var/www/html/sites/

echo "Restore completed successfully!"
