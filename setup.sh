#!/bin/bash
# setup.sh - builds the Docker environment for the Drupal project:
# a network, a PostgreSQL container and a Drupal container.

NETWORK="drupal-net"
DB_CONTAINER="drupal-db"
APP_CONTAINER="drupal-app"
DB_IMAGE="postgres:latest"
APP_IMAGE="drupal:latest"
DB_NAME="drupal"
DB_USER="root"
DB_PASSWORD="my-secret-pw"
DB_VOLUME="drupal-db-data"
APP_VOLUME="drupal-sites"

echo "=== Drupal project setup ==="

if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running. Start Docker and try again."
    exit 1
fi

# 1. Network
if docker network inspect "$NETWORK" > /dev/null 2>&1; then
    echo "[1/4] Network '$NETWORK' already exists"
else
    echo "[1/4] Creating network '$NETWORK'..."
    docker network create "$NETWORK"
fi

# 2. Images
echo "[2/4] Pulling latest images (this may take a few minutes)..."
docker pull -q "$DB_IMAGE"
docker pull -q "$APP_IMAGE"

# 3. Database container
if docker ps -a --format '{{.Names}}' | grep -qx "$DB_CONTAINER"; then
    echo "[3/4] Container '$DB_CONTAINER' already exists - starting it"
    docker start "$DB_CONTAINER" > /dev/null
else
    echo "[3/4] Starting PostgreSQL container '$DB_CONTAINER'..."
    docker run -d --name "$DB_CONTAINER" --network "$NETWORK" \
        -e POSTGRES_USER="$DB_USER" \
        -e POSTGRES_PASSWORD="$DB_PASSWORD" \
        -e POSTGRES_DB="$DB_NAME" \
        -p 5432:5432 \
        -v "$DB_VOLUME":/var/lib/postgresql \
        "$DB_IMAGE"
fi

echo "      Waiting for the database to be ready..."
# During first-time init Postgres only listens on a local socket, so wait for TCP
until docker exec "$DB_CONTAINER" pg_isready -h 127.0.0.1 -U "$DB_USER" -d "$DB_NAME" > /dev/null 2>&1; do
    sleep 2
done
# Drupal requires the pg_trgm extension on PostgreSQL
docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -q \
    -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;" > /dev/null
echo "      Database is ready"

# 4. Drupal container
if docker ps -a --format '{{.Names}}' | grep -qx "$APP_CONTAINER"; then
    echo "[4/4] Container '$APP_CONTAINER' already exists - starting it"
    docker start "$APP_CONTAINER" > /dev/null
else
    echo "[4/4] Starting Drupal container '$APP_CONTAINER'..."
    docker run -d --name "$APP_CONTAINER" --network "$NETWORK" \
        -p 8080:80 \
        -v "$APP_VOLUME":/var/www/html/sites \
        "$APP_IMAGE"
fi

echo ""
docker ps --filter "network=$NETWORK"
echo ""
echo "=== Setup complete ==="
echo "Open http://localhost:8080 in your browser."
echo "Database settings for the Drupal installer:"
echo "  Type: PostgreSQL | Name: $DB_NAME | User: $DB_USER | Password: $DB_PASSWORD"
echo "  Advanced options -> Host: $DB_CONTAINER | Port: 5432"