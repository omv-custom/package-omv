Add the following line to */etc/apt/sources.list.d/openmediavault.list* to use this package repository. A Backup

``wget -O - https://gekomod.github.io/package-omv/omv.gpg | sudo apt-key add -``

``echo "deb https://gekomod.github.io/package-omv/ stable main" | sudo tee /etc/apt/sources.list.d/omv-custom.list``
