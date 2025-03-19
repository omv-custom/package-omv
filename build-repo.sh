#!/bin/bash

REPO_DIR="/home/zaba/Dokumenty/package-omv"
cd $REPO_DIR

# Aktualizuj metadane
dpkg-scanpackages pool/main /dev/null | gzip -9c > dists/stable/main/binary-amd64/Packages.gz

# Aktualizuj plik Release
cd dists/stable/
cat <<EOF > Release
Origin: Your Repository Name
Label: Your Repository Label
Suite: stable
Codename: stable
Version: 1.0
Architectures: amd64
Components: main
Description: Your custom Debian repository
Date: $(date -Ru)
EOF

# Podpisz plik Release
gpg --default-key your-email@example.com --armor --detach-sign --output Release.gpg Release
gpg --default-key your-email@example.com --clearsign --output InRelease Release
