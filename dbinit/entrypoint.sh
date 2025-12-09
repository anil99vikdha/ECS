#!/bin/sh
set -e

echo "MYSQL_HOST=$MYSQL_HOST"
echo "Running DB init..."

mysql --disable-ssl -h "$MYSQL_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < /init.sql

echo "DB init completed successfully"