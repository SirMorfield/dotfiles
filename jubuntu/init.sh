#!/bin/bash

set -o xtrace  # Print commands as they are executed
set -o errexit # Exit on error


if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

cd /root


# ========================= Install dependencies =========================
apt-get update

apt-get install -y -qq \
    curl \
    jq \
    git \
    libicu-dev \
	unzip \
	gnupg \
	locales

# Set locales
localedef -i en_UK -c -f UTF-8 -A /usr/share/locale/locale.alias en_UK.UTF-8
ENV LANG en_UK.utf8

# Install doctl, for authenticating with the k8s cluster
curl -L https://github.com/digitalocean/doctl/releases/download/v1.123.0/doctl-1.123.0-linux-amd64.tar.gz -o doctl.tar.gz && \
    tar xf doctl.tar.gz && \
    mv doctl /usr/local/bin && \
    chmod +x /usr/local/bin/doctl && \
    rm -f doctl.tar.gz
doctl version


# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
	install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

# Install docker
curl -fsSL https://get.docker.com | sh && \
	usermod -aG docker root

docker --version

# Install bun
curl -fsSL https://bun.sh/install | bash && \
	cp /root/.bun/bin/bun /usr/local/bin/bun

bun --version

# Install nodejs
curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
	apt-get install -y -qq nodejs && \


# ========================= Configure environment =========================

curl -sS https://github.com/SirMorfield.keys >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
sed -i 's/^#\?\(PasswordAuthentication\) .*/\1 no/; s/^#\?\(PermitRootLogin\) .*/\1 yes/' /etc/ssh/sshd_config
sed -i '/^#\?PermitRootLogin/c\PermitRootLogin yes' /etc/ssh/sshd_config
systemctl restart sshd

mkdir -p git
git clone git@github.com:SirMorfield/dotfiles.git git/dotfiles





# Clean up apt cache
rm -rf /var/lib/apt/lists/*
