Add the following line to */etc/apt/sources.list.d/openmediavault.list* to use this package repository. A Backup

``wget -O - https://omv-custom.github.io/package-omv/public-omv.key | sudo apt-key add -``

``echo "deb https://omv-custom.github.io/package-omv/ stable main" | sudo tee /etc/apt/sources.list.d/omv-custom.list``
