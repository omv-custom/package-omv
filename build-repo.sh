#!/bin/bash

# Skrypt do budowy własnego repozytorium Debian z plikami .deb z katalogu /pool/main
# oraz utworzenia klucza GPG do podpisywania repozytorium.

# Konfiguracja
REPO_DIR="/home/zaba/Dokumenty/package-omv"  # Ścieżka do katalogu repozytorium
POOL_DIR="$REPO_DIR/pool/main"  # Ścieżka do katalogu z plikami .deb
DIST="stable"  # Nazwa dystrybucji (np. stable, testing)
ARCH="amd64"  # Architektura (np. amd64, arm64)
GPG_NAME="OMVCUSTOM"  # Nazwa do klucza GPG
GPG_EMAIL="contact@openmediavault.pl"  # Email do klucza GPG

# Utwórz katalogi repozytorium
mkdir -p "$REPO_DIR/dists/$DIST/main/binary-$ARCH"
mkdir -p "$REPO_DIR/pool/main"

# Przejdź do katalogu repozytorium
cd "$REPO_DIR"

# 1. Utwórz klucz GPG
echo "Tworzenie klucza GPG..."
gpg --batch --gen-key <<EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $GPG_NAME
Name-Email: $GPG_EMAIL
Expire-Date: 0
%no-protection
%commit
EOF

# Eksportuj klucz publiczny
echo "Eksportowanie klucza publicznego..."
gpg --armor --export "$GPG_EMAIL" > "$REPO_DIR/KEY.gpg"

# 2. Zbuduj repozytorium
echo "Budowanie repozytorium..."

# Utwórz plik Packages.gz
cd "$POOL_DIR"
dpkg-scanpackages . /dev/null | gzip -9c > "$REPO_DIR/dists/$DIST/main/binary-$ARCH/Packages.gz"

# Utwórz plik Release
cd "$REPO_DIR/dists/$DIST"
cat <<EOF > Release
Origin: Custom Debian Repository
Label: Custom Repo
Suite: $DIST
Codename: $DIST
Architectures: $ARCH
Components: main
Description: Custom Debian Repository
Date: $(date -Ru)
EOF

# Dodaj sumy kontrolne do pliku Release
echo "MD5Sum:" >> Release
md5sum main/binary-$ARCH/Packages.gz | awk '{print $1, $2}' >> Release
echo "SHA1:" >> Release
sha1sum main/binary-$ARCH/Packages.gz | awk '{print $1, $2}' >> Release
echo "SHA256:" >> Release
sha256sum main/binary-$ARCH/Packages.gz | awk '{print $1, $2}' >> Release

# 3. Podpisz plik Release za pomocą GPG
echo "Podpisywanie pliku Release..."
gpg --armor --detach-sign --output Release.gpg Release
gpg --clearsign --output InRelease Release

# 4. Zakończenie
echo "Repozytorium zostało utworzone w katalogu: $REPO_DIR"
echo "Klucz publiczny GPG znajduje się w pliku: $REPO_DIR/KEY.gpg"
echo "Możesz dodać repozytorium do systemu, używając następujących poleceń:"
echo "sudo apt-key add $REPO_DIR/KEY.gpg"
echo "sudo echo 'deb [arch=$ARCH] file://$REPO_DIR $DIST main' > /etc/apt/sources.list.d/custom-repo.list"
echo "sudo apt update"
