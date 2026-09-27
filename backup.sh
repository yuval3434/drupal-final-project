#!/bin/bash
set -e
echo "Starting backup process..."

echo "Backing up the PostgreSQL database..."
docker exec drupal-db sh -c 'exec pg_dump -U root drupal' > drupal_db_backup.sql

echo "Backing up the Drupal sites folder..."
docker exec drupal-app tar -C /var/www/html -czf - sites > sites_backup.tar.gz

echo "Backup completed successfully!"
