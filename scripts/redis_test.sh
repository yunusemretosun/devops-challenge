#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="redis"
SECRET_NAME="redis-secret"
SERVICE_NAME="redis-master"

REDIS_PORT=$(kubectl get svc -n $NAMESPACE $SERVICE_NAME -o jsonpath='{.spec.ports[0].nodePort}')
REDIS_HOST=$(kubectl get node -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
REDIS_PASS=$(kubectl get secret $SECRET_NAME -n $NAMESPACE -o jsonpath="{.data.redis-password}" | base64 -d)

echo "Veri cache’liyor ve tekrar çekiyor:"
redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASS set testkey "hello_cache"
redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASS get testkey

