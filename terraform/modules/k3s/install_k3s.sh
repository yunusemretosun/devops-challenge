#!/usr/bin/env bash
set -euo pipefail

# Eğer k3s yüklü değilse kur
if ! command -v k3s &>/dev/null; then
  echo ">>> Installing k3s..."
  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik" sh -
else
  echo ">>> k3s already installed, skipping."
fi

# kubeconfig’i kopyala ve izinlerini düzelt
mkdir -p "$HOME/.kube"
sudo cp /etc/rancher/k3s/k3s.yaml "$HOME/.kube/config"
sudo chown "$(id -u):$(id -g)" "$HOME/.kube/config"

# .bashrc’ye env ekle
if ! grep -qxF 'export KUBECONFIG=$HOME/.kube/config' ~/.bashrc; then
  echo '' >> ~/.bashrc
  echo '# k3s kubeconfig' >> ~/.bashrc
  echo 'export KUBECONFIG=$HOME/.kube/config' >> ~/.bashrc
  echo ">>> Added KUBECONFIG to ~/.bashrc"
else
  echo ">>> KUBECONFIG already in ~/.bashrc, skipping."
fi

