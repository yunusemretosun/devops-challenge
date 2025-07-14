#!/usr/bin/env bash
set -euo pipefail

NAMESPACE=postgresql
SECRET=my-postgres-secret

# Secret'lardan bilgileri çek
PGUSER=$(kubectl get secret --namespace $NAMESPACE $SECRET -o jsonpath="{.data.username}" | base64 -d)
PGPASSWORD=$(kubectl get secret --namespace $NAMESPACE $SECRET -o jsonpath="{.data.password}" | base64 -d)
PGDATABASE=$(kubectl get secret --namespace $NAMESPACE $SECRET -o jsonpath="{.data.database}" | base64 -d)

# NodePort'u al
PGPORT=$(kubectl get svc postgresql -n $NAMESPACE -o jsonpath="{.spec.ports[0].nodePort}")
PGHOST=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')

echo "Bağlanılan DB: $PGDATABASE"
echo "Kullanıcı: $PGUSER"
echo "Host: $PGHOST"
echo "Port: $PGPORT"

# psql ile bağlan
PGPASSWORD=$PGPASSWORD psql -h $PGHOST -p $PGPORT -U $PGUSER -d $PGDATABASE -c "\l"

