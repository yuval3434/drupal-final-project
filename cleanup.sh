#!/bin/bash
# cleanup.sh - removes everything setup.sh created: containers, images,
# volumes and the network, leaving Docker as it was before the project.

NETWORK="drupal-net"
DB_CONTAINER="drupal-db"
APP_CONTAINER="drupal-app"
DB_IMAGE="postgres:latest"
APP_IMAGE="drupal:latest"
DB_VOLUME="drupal-db-data"
APP_VOLUME="drupal-sites"

echo "=== Drupal project cleanup ==="
echo "WARNING: this deletes the site and its database from this machine."
echo "(The backup files in this repository are not deleted.)"
read -r -p "Continue? [y/N] " answer
if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo "[1/4] Removing containers..."
docker rm -f "$APP_CONTAINER" "$DB_CONTAINER" 2> /dev/null

echo "[2/4] Removing images..."
docker rmi "$APP_IMAGE" "$DB_IMAGE" 2> /dev/null

echo "[3/4] Removing volumes..."
docker volume rm "$APP_VOLUME" "$DB_VOLUME" 2> /dev/null

echo "[4/4] Removing network..."
docker network rm "$NETWORK" 2> /dev/null

echo ""
echo "Remaining project resources (should be empty):"
docker ps -a --filter "name=drupal"
docker volume ls --filter "name=drupal"
docker network ls --filter "name=$NETWORK"
echo ""
echo "=== Cleanup complete ==="