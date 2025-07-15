# DevOps Challenge – Local Kubernetes Demo

Bu repoda, yerel bir Kubernetes ortamında PostgreSQL, Redis ve örnek bir uygulamanın CI/CD ile yönetimini bulacaksınız.

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
- `curl`, `git`, `kubectl`, `helm`, `terraform` (otomatik kurulur)
- DockerHub hesabı (örnek uygulama için)

### 2. Kurulum

1. Depoyu klonla:
   ```sh
   git clone <repo-url>
   cd devops-case

2. Ortam Kurulumu:
   bash scripts/setup_environment.sh

3. Jenkins,redis,postgresql Kurulumu
```sh
  	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo update
	# Secret’ı oluştur
	kubectl create secret generic my-postgres-secret \
	  --from-literal=postgres-password=supersecretpass \
	  --from-literal=password=devpass \
	  -n postgresql
	
	# PostgreSQL’i kur
	helm upgrade --install postgresql bitnami/postgresql \
	  -n postgresql -f helm-charts/postgresql/values.yaml
	
	# Redis’i kur
	kubectl create secret generic redis-password \
	  --from-literal=password=supersecretredis \
	  -n redis
	helm upgrade --install redis bitnami/redis \
	  -n redis -f helm-charts/redis/values.yaml
