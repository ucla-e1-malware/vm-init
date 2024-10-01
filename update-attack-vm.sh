#!/bin/bash

# update-attack-vm.sh: a helper script to bootstrap the E1 Malware Attack VM

# become root (you should be able to understand this block by the end of the course :D)
if [ "$(id -u)" -ne 0 ]; then
  sudo $0
  exit $?
fi

die () {
  EXIT_CODE=$?
  echo "❌ $1" >&2
  exit $EXIT_CODE
}

# returns true if the package $1 is not installed
needs_install () {
    [ "$(dpkg -l "$1" > /dev/null 2>&1; echo $?)" -eq 1 ]
}

if needs_install software-properties-common; then
    echo "⚙️ Installing software-properties-common..."
    apt update || die "Failed to run apt update"
    apt install software-properties-common || die "Failed to install software-properties-common"
fi

if needs_install ansible; then
    echo "🐮 Installing Ansible..."
    add-apt-repository --yes --update ppa:ansible/ansible || die "Failed to add the Ansible PPA"
    apt update || die "Failed to run apt update"
    apt install ansible || die "Failed to install Ansible"
fi

echo "📥 Pulling Ansible config..."
ansible-pull -U https://github.com/ucla-e1-malware/vm-init playbooks/attack.yaml
