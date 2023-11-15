#!/usr/bin/env bash
source ./setup/data/build.conf && export MYSQL_ROOT_PASSWORD
docker compose up -d

echo "Waiting to complete container up...."
sleep 10
echo "Install Database...."

sleep 1
echo "Setup schema..."
docker exec -it mysql-service sh -c 'bin/mysql -u root -p$MYSQL_ROOT_PASSWORD < /docker-entrypoint-initdb.d/setup-schema.sql && exit;'

sleep 5
echo "Setup data..."
docker exec -it mysql-service sh -c 'bin/mysql -u root -p$MYSQL_ROOT_PASSWORD < /docker-entrypoint-initdb.d/insert-data.sql && exit'

echo "Install successfully!"
sleep 2