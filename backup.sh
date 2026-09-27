#!/bin/bash
echo "Starting backup process..."
docker exec drupal-db sh -c 'exec pg_dump -U root drupal' > drupal_db_backup.sql
docker cp drupal-app:/var/www/html/sites ./sites_backup
echo "Backup completed successfully!"
