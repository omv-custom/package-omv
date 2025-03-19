#!/bin/bash

# Konfiguracja
REPO_DIR="/home/zaba/Dokumenty/package-omv"  # Ścieżka do katalogu repozytorium
POOL_DIR="$REPO_DIR/pool/main"  # Ścieżka do katalogu z plikami .deb
DIST_DIR="$REPO_DIR/dists/stable/main/binary-amd64"  # Ścieżka do dystrybucji
GPG_KEY_NAME="debian-repo-key"  # Nazwa klucza GPG
GPG_KEY_EMAIL="contact@openmediavault.pl"  # Email do klucza GPG

# 1. Utwórz strukturę katalogów repozytorium
mkdir -p "$POOL_DIR"
mkdir -p "$DIST_DIR"

# 2. Utwórz klucz GPG (jeśli nie istnieje)
if ! gpg --list-keys "$GPG_KEY_EMAIL" > /dev/null 2>&1; then
  echo "Tworzenie nowego klucza GPG..."
  gpg --batch --gen-key <<EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $GPG_KEY_NAME
Name-Email: $GPG_KEY_EMAIL
Expire-Date: 0
%no-protection
EOF
fi

# 3. Eksportuj klucz publiczny
echo "Eksportowanie klucza publicznego..."
gpg --armor --export "$GPG_KEY_EMAIL" > "$REPO_DIR/public-omv.key"

# 4. Przenieś pliki .deb do katalogu /pool/main (jeśli nie są już tam umieszczone)
if [ ! -z "$(ls -A /path/to/your/debs/*.deb 2>/dev/null)" ]; then
  echo "Przenoszenie plików .deb do $POOL_DIR..."
  mv /path/to/your/debs/*.deb "$POOL_DIR"
fi

# 5. Utwórz plik Packages.gz
echo "Tworzenie pliku Packages.gz..."
cd "$REPO_DIR"
dpkg-scanpackages -m pool/main > "$DIST_DIR/Packages"
gzip -k -f "$DIST_DIR/Packages"

# 6. Utwórz plik Release
echo "Tworzenie pliku Release..."
cd "$REPO_DIR/dists/stable"
cat <<EOF > Release
Origin: Your Debian Repository
Label: Your Debian Repository
Codename: stable
Architectures: amd64
Components: main
Description: Custom Debian Repository
Date: $(date -Ru)
EOF
apt-ftparchive release . >> Release

# 7. Podpisz plik Release kluczem GPG
echo "Podpisywanie pliku Release..."
gpg --default-key "$GPG_KEY_EMAIL" --digest-algo SHA512 -abs -o Release.gpg Release
gpg --default-key "$GPG_KEY_EMAIL" --digest-algo SHA512 -abs --clearsign -o InRelease Release

# 8. Zakończ
echo "Repozytorium zostało pomyślnie utworzone w $REPO_DIR."
echo "Klucz publiczny znajduje się w $REPO_DIR/public-omv.key."
