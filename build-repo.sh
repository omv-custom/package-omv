#!/bin/bash

# Konfiguracja
REPO_DIR="/home/zaba/Dokumenty/package-omv"
DIST="stable"
ARCH="amd64"
GPG_KEY_NAME="Your Name <your.email@example.com>"

# Tworzenie katalogów
mkdir -p "${REPO_DIR}/dists/${DIST}/main/binary-${ARCH}"
mkdir -p "${REPO_DIR}/db"

# Generowanie klucza GPG (jeśli nie istnieje)
if ! gpg --list-keys "${GPG_KEY_NAME}" > /dev/null 2>&1; then
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

# Tworzenie pliku Packages.gz
echo "Tworzenie pliku Packages.gz..."
cd "${REPO_DIR}/pool/main"
find . -name '*.deb' -exec dpkg-deb -f {} > /tmp/control.tmp \;
cat /tmp/control.tmp | awk '/Package:/ {print $2}' | sort | uniq | while read -r package; do
  find . -name "${package}_*.deb" -exec dpkg-deb -f {} > "${REPO_DIR}/dists/${DIST}/main/binary-${ARCH}/Packages" \;
done
gzip -k -f "${REPO_DIR}/dists/${DIST}/main/binary-${ARCH}/Packages"

# Tworzenie pliku Release
echo "Tworzenie pliku Release..."
cd "${REPO_DIR}/dists/${DIST}"
cat <<EOF > Release
Origin: Your Repository
Label: Your Repository
Suite: ${DIST}
Codename: ${DIST}
Architectures: ${ARCH}
Components: main
Description: Your custom Debian repository
Date: $(date -Ru)
EOF
apt-ftparchive release . >> Release

# Podpisywanie pliku Release
echo "Podpisywanie pliku Release..."
gpg --armor --detach-sign --output Release.gpg Release
gpg --clearsign --output InRelease Release

# Tworzenie bazy danych pakietów
echo "Tworzenie bazy danych pakietów..."
cd "${REPO_DIR}/db"
sqlite3 packages.db <<EOF
CREATE TABLE IF NOT EXISTS packages (
  name TEXT PRIMARY KEY,
  version TEXT,
  architecture TEXT,
  description TEXT
);
EOF

# Dodawanie pakietów do bazy danych
find "${REPO_DIR}/pool/main" -name '*.deb' | while read -r deb_file; do
  package_name=$(dpkg-deb -f "${deb_file}" Package)
  package_version=$(dpkg-deb -f "${deb_file}" Version)
  package_arch=$(dpkg-deb -f "${deb_file}" Architecture)
  package_desc=$(dpkg-deb -f "${deb_file}" Description)

  sqlite3 packages.db <<EOF
    INSERT OR REPLACE INTO packages (name, version, architecture, description)
    VALUES ('${package_name}', '${package_version}', '${package_arch}', '${package_desc}');
EOF
done

echo "Repozytorium zostało pomyślnie zbudowane!"
