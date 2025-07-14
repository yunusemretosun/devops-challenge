kubectl create secret generic my-postgres-secret \
  --from-literal=postgres-password=changeme123 \
  --from-literal=password=changeme \

helm upgrade --install postgresql bitnami/postgresql \
  --namespace postgresql \
  -f values.yaml
