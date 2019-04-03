#!/bin/bash

set -e

OS=$(uname | tr '[:upper:]' '[:lower:]')

echo "Upgrading kubectl"

curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/${OS}/amd64/kubectl"
chmod +x ./kubectl

if [ -x "$(command -v kubectl)" ]; then
  sudo mv ./kubectl `which kubectl`
else
  sudo mv ./kubectl /usr/local/bin/kubectl
fi

kubectl version
