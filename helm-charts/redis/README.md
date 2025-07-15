kubectl create ns redis

kubectl create secret generic redis-secret \
  --from-literal=redis-password=superredispass \
  -n redis

helm upgrade --install redis bitnami/redis \
  --namespace redis \
  -f values.yaml
