#!/bin/bash

# Konfiguracja
REPO_DIR="/home/zaba/Dokumenty/package-omv"  # Ścieżka do katalogu repozytorium
POOL_DIR="$REPO_DIR/pool/main" # Ścieżka do katalogu z plikami .deb
DIST="stable"                  # Nazwa dystrybucji (np. stable, testing)
ARCH="amd64"                   # Architektura (np. amd64, arm64)
GPG_KEY="your-gpg-key-id"      # ID klucza GPG do podpisywania repozytorium

# Tworzenie katalogów
mkdir -p "$REPO_DIR/dists/$DIST/main/binary-$ARCH"
mkdir -p "$REPO_DIR/pool/main"

# Przejdź do katalogu repozytorium
cd "$REPO_DIR"

# Generowanie pliku Packages
echo "Generowanie pliku Packages..."
apt-ftparchive packages pool/main > dists/$DIST/main/binary-$ARCH/Packages
gzip -k -f dists/$DIST/main/binary-$ARCH/Packages

# Generowanie pliku Release
echo "Generowanie pliku Release..."
cat <<EOF > dists/$DIST/Release
Origin: Your Repository Name
Label: Your Repository Label
Suite: $DIST
Codename: $DIST
Architectures: $ARCH
Components: main
Description: Your custom Debian repository
Date: $(date -Ru)
EOF

apt-ftparchive release dists/$DIST >> dists/$DIST/Release

# Podpisywanie pliku Release za pomocą GPG
echo "Podpisywanie pliku Release..."
gpg --default-key "$GPG_KEY" --digest-algo SHA256 -abs -o dists/$DIST/Release.gpg dists/$DIST/Release
gpg --default-key "$GPG_KEY" --digest-algo SHA256 -abs --clearsign -o dists/$DIST/InRelease dists/$DIST/Release

echo "Repozytorium zostało pomyślnie zbudowane!"
