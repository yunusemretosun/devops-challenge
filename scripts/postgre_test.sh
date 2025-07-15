#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="postgresql"
SECRET_NAME="my-postgres-secret"
PG_SERVICE="postgresql"

PG_PORT=$(kubectl get svc -n $NAMESPACE $PG_SERVICE -o jsonpath='{.spec.ports[0].nodePort}')
PG_HOST=$(kubectl get node -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
PGUSER=$(kubectl get secret $SECRET_NAME -n $NAMESPACE -o jsonpath="{.data.username}" | base64 -d)
PGPASS=$(kubectl get secret $SECRET_NAME -n $NAMESPACE -o jsonpath="{.data.password}" | base64 -d)
PGDB=$(kubectl get secret $SECRET_NAME -n $NAMESPACE -o jsonpath="{.data.database}" | base64 -d)

echo "Creating tables (skip if exists):"
PGPASSWORD=$PGPASS psql -h $PG_HOST -p $PG_PORT -U $PGUSER -d $PGDB -c "CREATE TABLE IF NOT EXISTS testtable(id SERIAL PRIMARY KEY, name TEXT);"

echo "Adding data:"
PGPASSWORD=$PGPASS psql -h $PG_HOST -p $PG_PORT -U $PGUSER -d $PGDB -c "INSERT INTO testtable(name) VALUES('hello_persistent');"

echo "Checking data:"
PGPASSWORD=$PGPASS psql -h $PG_HOST -p $PG_PORT -U $PGUSER -d $PGDB -c "SELECT * FROM testtable;"

