#create ns
kubectl create namespace jenkins
#roles required for crud operations on diffrent namespaces
kubectl apply -f roles.yaml
#admin login secret
kubectl create secret generic jenkins-admin-secret \
  --from-literal=jenkins-admin-password=changeme \
  -n jenkins
#install
helm upgrade --install jenkins jenkins/jenkins \
  --namespace jenkins \
  -f values.yaml \
  --wait --timeout 3m
