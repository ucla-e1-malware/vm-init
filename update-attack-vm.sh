#!/bin/bash

# update-vm.sh: a helper script to bootstrap the E1 Malware VM

# become root (you should be able to understand this by the end of the course :D)
if [ "$(id -u)" -ne 0 ]; then
  pkexec $0
  exit $?
fi

# returns true if the package $1 is not installed
needs_install () {
    [ "$(dpkg -l "$1" > /dev/null 2>&1; echo $?)" -eq 1 ]
}

apt update

if needs_install software-properties-common; then
    echo "⚙️ Installing software-properties-common..."
    apt install software-properties-common
fi

if needs_install ansible; then
    echo "🐮 Installing Ansible..."
    add-apt-repository --yes --update ppa:ansible/ansible
    apt install ansible
fi

echo "📥 Pulling ansible config..."
ansible-pull -U https://github.com/ucla-e1-malware/vm-init playbooks/attack.yaml
