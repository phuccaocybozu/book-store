#!/usr/bin/env zsh
source ./setup/data/build.conf && export MYSQL_ROOT_PASSWORD
docker compose up -d

echo "Waiting to complete container up...."
sleep 20
echo "Install Database...."

sleep 1
echo "Setup schema..."
docker exec -it mysql-service sh -c 'bin/mysql --defaults-extra-file=/docker-entrypoint-initdb.d/mysql.conf < /docker-entrypoint-initdb.d/setup-schema.sql && exit;'

sleep 5
echo "Setup data..."
docker exec -it mysql-service sh -c 'bin/mysql --defaults-extra-file=/docker-entrypoint-initdb.d/mysql.conf < /docker-entrypoint-initdb.d/insert-data.sql && exit'

echo "Install successfully!"
sleep 5
docker compose rm init-kafka -f
