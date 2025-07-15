#install
helm upgrade --install jenkins jenkins/jenkins \
  --namespace jenkins \
  --create-namespace \
  -f values.yaml \
  --wait --timeout 3m

#ui credentials 
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo

#access ui via. run in terminal and copy paste output to your browser
echo "http://$(hostname -I | awk '{print $1}'):30080"

#roles required for crud operations on different namespaces
kubectl apply -f roles.yaml
