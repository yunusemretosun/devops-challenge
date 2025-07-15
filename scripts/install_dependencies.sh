#!/usr/bin/env bash
set -euo pipefail

echo ">>> Updating package lists..."
sudo apt update && sudo apt upgrade -y

echo ">>> Installing required packages..."
sudo apt-get install -y curl git gnupg redis-tools postgresql-client software-properties-common apt-transport-https ca-certificates unzip

### Install Terraform
if ! command -v terraform &>/dev/null; then
  echo ">>> Terraform is not installed, downloading..."
  TF_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform \
    | grep -Po '"current_version":"\K[0-9.]+' )
  curl -fsSL "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" \
    -o terraform.zip
  unzip -p terraform.zip terraform > terraform && chmod +x terraform
  sudo mv terraform /usr/local/bin/
  rm -f terraform.zip LICENSE.txt
else
  echo ">>> Terraform is already installed: $(terraform version | head -n1)"
fi

### Install kubectl
if ! command -v kubectl &>/dev/null; then
  echo ">>> kubectl is not installed, downloading..."
  K8S_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
  curl -fsSL "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl" \
    -o kubectl && chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
else
  echo ">>> kubectl is already installed: $(kubectl version --client | head -n1)"
fi

### Install Helm
if ! command -v helm &>/dev/null; then
  echo ">>> Helm is not installed, downloading..."
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
  echo ">>> Helm is already installed: $(helm version --template='v{{ .Version }}')"
fi

# -----------------------------
# Helm Repos
# -----------------------------
echo ">>> Adding and updating Helm repositories..."
helm repo add jenkins https://charts.jenkins.io 2>/dev/null || echo "jenkins repo already exists"
helm repo add bitnami https://charts.bitnami.com/bitnami 2>/dev/null || echo "bitnami repo already exists"
helm repo update

### Final Check
echo
echo ">>> All installations completed. Versions:"
echo "- $(terraform version | head -n1)"
echo "- $(kubectl version --client | head -n1)"
echo "- $(helm version --template='v{{ .Version }}')"

