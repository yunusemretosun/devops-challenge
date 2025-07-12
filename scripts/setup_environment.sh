#!/usr/bin/env bash
set -euo pipefail

# 1) CLI araçlarını kur
echo "=== 1) Installing CLI tools ==="
./scripts/install_dependencies.sh

# 2) k3s cluster’ı kur (Terraform)
echo
echo "=== 2) Terraform apply for k3s ==="
pushd terraform >/dev/null
terraform init
terraform apply -auto-approve
popd >/dev/null

# 3) KUBECONFIG yolunu bu oturuma ekle
export KUBECONFIG="$HOME/.kube/config"

echo
echo " Setup complete!"

