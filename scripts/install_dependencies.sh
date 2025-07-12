#!/usr/bin/env bash
set -euo pipefail

echo ">>> Paket listelerini güncelliyorum..."
sudo apt update && sudo apt upgrade -y

echo ">>> Gerekli genel paketleri yüklüyorum..."
sudo apt-get install -y curl git gnupg software-properties-common apt-transport-https ca-certificates unzip

### Terraform kurulumu
if ! command -v terraform &>/dev/null; then
  echo ">>> Terraform yüklü değil, indiriliyor..."
  TF_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform \
    | grep -Po '"current_version":"\K[0-9.]+' )
  curl -fsSL "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" \
    -o terraform.zip
  unzip -p terraform.zip terraform > terraform && chmod +x terraform
  sudo mv terraform /usr/local/bin/
  rm -f terraform.zip LICENSE.txt
else
  echo ">>> Terraform zaten kurulu: $(terraform version | head -n1)"
fi

### kubectl kurulumu
if ! command -v kubectl &>/dev/null; then
  echo ">>> kubectl yüklü değil, indiriliyor..."
  K8S_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
  curl -fsSL "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl" \
    -o kubectl && chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
else
  echo ">>> kubectl zaten kurulu: $(kubectl version --client | head -n1)"
fi

### Helm kurulumu
if ! command -v helm &>/dev/null; then
  echo ">>> Helm yüklü değil, indiriliyor..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
  echo ">>> Helm zaten kurulu: $(helm version --template='v{{ .Version }}')"
fi

### Son Kontrol
echo
echo ">>> Tüm yüklemeler tamamlandı. Sürümler:"
echo "- $(terraform version | head -n1)"
echo "- $(kubectl version --client | head -n1)"
echo "- $(helm version --template='v{{ .Version }}')"

