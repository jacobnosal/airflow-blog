#!/usr/bin/env bash

set -x

username="$1"
password="$2"
server="$3"
db="$4"
user_to_create="$5"
user_password="$6"

connection_string="host=$server.postgres.database.azure.com port=5432 dbname=$db user=$username@$server password=$password sslmode=require"
psql \
    "$connection_string" \
    -c "CREATE USER $user_to_create WITH PASSWORD '$user_password';" \
    -c "GRANT ALL PRIVILEGES ON DATABASE $db TO $user_to_create;"