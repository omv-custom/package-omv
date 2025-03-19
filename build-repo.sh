#!/bin/bash

# Konfiguracja
REPO_DIR="/home/zaba/Dokumenty/package-omv"  # Ścieżka do katalogu repozytorium
POOL_DIR="$REPO_DIR/pool/main" # Ścieżka do katalogu z plikami .deb
DIST_DIR="$REPO_DIR/dists/stable/main/binary-amd64" # Ścieżka do dystrybucji
GPG_KEY_NAME="contact@openmediavault.pl" # Nazwa klucza GPG

# Utwórz katalogi repozytorium
mkdir -p "$DIST_DIR"

# Przejdź do katalogu z plikami .deb
cd "$POOL_DIR"

# Utwórz plik Packages.gz
dpkg-scanpackages . /dev/null | gzip -9c > "$DIST_DIR/Packages.gz"

# Utwórz plik Release
cd "$REPO_DIR/dists/stable"
cat <<EOF > Release
Origin: Your Repository
Label: Your Repository
Suite: stable
Codename: stable
Version: 1.0
Architectures: amd64
Components: main
Description: Your custom Debian repository
Date: $(date -Ru)
EOF

# Dodaj sumy kontrolne do pliku Release
apt-ftparchive release . >> Release

# Wygeneruj klucz GPG (jeśli nie istnieje)
if ! gpg --list-keys "$GPG_KEY_NAME" > /dev/null 2>&1; then
  echo "Generowanie nowego klucza GPG..."
  gpg --batch --gen-key <<EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: Your Name
Name-Email: your.email@example.com
Expire-Date: 0
%commit
EOF
fi

# Podpisz plik Release
gpg --armor --detach-sign -o Release.gpg Release
gpg --clearsign -o InRelease Release

echo "Repozytorium zostało utworzone w katalogu: $REPO_DIR"
echo "Klucz GPG został wygenerowany i użyty do podpisania repozytorium."

gpg --export --armor "$GPG_KEY_NAME" > omv.asc
