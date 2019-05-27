#!/bin/bash

set -e

if [ `id -u` -ne 0 ]; then
  echo "please run with root"
  exit 1
fi

OS=$(uname | tr '[:upper:]' '[:lower:]')

echo "Upgrading kubectl"

curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/${OS}/amd64/kubectl"
chmod +x ./kubectl

if [ -x "$(command -v kubectl)" ]; then
  mv ./kubectl `which kubectl`
else
  mv ./kubectl /usr/local/bin/kubectl
fi

kubectl version --client
