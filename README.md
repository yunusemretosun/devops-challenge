# DevOps Challenge

## Proje Kapsamı

- Tüm kurulum ve yönetim adımları tek bir repoda tutulur.
- Tüm parola ve hassas bilgiler Kubernetes Secret olarak saklanır.
- PostgreSQL ve Redis Helm Chart ile kurulup yapılandırılır.
- Jenkins ile uygulama build/deploy işlemleri yapılır.
- Yedekleme ve dış erişim dahil, PostgreSQL ile veri kalıcılığı sağlanır.
- Redis ile cache kullanılabilir.
- CLI ile kurulum ve test scriptleriyle her şey doğrulanabilir.

## Kurulum Adımları

### 1. Gereksinimler

- Ubuntu 22.04+ (boş sanal makine)
- `curl`, `redis-cli`, `psql`, `git`, `kubectl`, `helm`, `terraform` (otomatik kurulur)
- DockerHub hesabı (örnek uygulama için)

### 2. Kurulum

1. Depoyu klonla:
```sh
git clone <repo-url>
cd devops-case

2. Ortam Kurulumu:
```sh
bash scripts/setup_environment.sh

3. Jenkins,redis,postgresql Kurulumu
```sh
# Namespace oluştur
kubectl create ns postgresql
kubectl create ns redis

# Secret’ları oluştur
kubectl create secret generic my-postgres-secret \
  --from-literal=postgres-password=<changeme> \
  --from-literal=password=<changeme> \
  -n postgresql

kubectl create secret generic redis-secret \
  --from-literal=redis-password=<changeme> \
  -n redis
	
# Jenkins'i kur
helm upgrade --install jenkins jenkins/jenkins \
  --namespace jenkins \
  --create-namespace \
  -f helm-charts/jenkins/values.yaml \
  --wait --timeout 3m
#requeired roles for deployment all namespaces
kubectl apply -f helm-charts/jenkins/roles.yaml
	
# PostgreSQL’i kur
helm upgrade --install postgresql bitnami/postgresql \
  -n postgresql -f helm-charts/postgresql/values.yaml
	
# Redis’i kur
helm upgrade --install redis bitnami/redis \
  -n redis -f helm-charts/redis/values.yaml
   
