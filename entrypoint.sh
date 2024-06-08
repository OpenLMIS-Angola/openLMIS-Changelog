#!/bin/bash

set -e

# Function to wait for PostgreSQL to be ready
wait_for_postgres() {
    local timeout=${DB_TIMEOUT:-300}
    local start_time=$(date +%s)

    until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER"; do
        local current_time=$(date +%s)
        if [ $((current_time - start_time)) -ge $timeout ]; then
            echo "Timed out waiting for PostgreSQL to be ready."
            exit 1
        fi
        echo "Waiting for PostgreSQL to be ready..."
        sleep 2
    done
}

# Wait for PostgreSQL to be ready
wait_for_postgres

# Execute the SQL script to create the changelog schema and table
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f /app/create_changelog.sql

# Execute the command provided to the container (e.g., create triggers)
exec "$@"
