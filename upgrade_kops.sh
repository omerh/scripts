#!/bin/bash

set -e

OS=$(uname | tr '[:upper:]' '[:lower:]')

if [[ "$OS" == "darwin" ]]; then
    SHABIN='shasum'
else
    SHABIN='sha1sum'
fi

echo "Upgrading kops"

curl -Lo kops https://github.com/kubernetes/kops/releases/download/"$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)"/kops-${OS}-amd64
SHA1=$(curl -L https://github.com/kubernetes/kops/releases/download/"$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)"/kops-${OS}-amd64-sha1)

echo "Verifying kops SHA1"

if [[ "$SHA1" == `$SHABIN kops | awk '{print $1}'` ]]; then
    chmod +x ./kops
    echo "SHA1 verifyed, replacing kops with sudo"
    if [ -x "$(command -v kops)" ]; then
        sudo mv ./kops `which kops`
    else
        sudo mv ./kops /usr/local/bin/kops
    fi
    kops version
else
    echo "SHA1 failed verification"
    exit 1
fi
