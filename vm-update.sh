#!/bin/bash

# vm-update.sh: a helper script to bootstrap the E1 Malware Attack and Target VMs

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
    ! dpkg -s "$1" > /dev/null 2>&1
}

# figure out which VM we're on
playbook=''
case "$(hostname)" in
  'e1-attack'|'e1-attack.local')
    playbook='attack' ;;
  'e1-target'|'e1-target.local')
    playbook='target' ;;
  *)
    die 'This script can only be run on either the e1-attack or e1-target VMs.
   (Did you try running this on your host machine by accident?)' ;;
esac

# bootstrap git
if needs_install git; then
    echo "⚙️ Installing git..."
    apt update || die "Failed to run apt update"
    apt install -y git || die "Failed to install git"
fi

# bootstrap ansible
if needs_install software-properties-common; then
    echo "⚙️ Installing software-properties-common..."
    apt update || die "Failed to run apt update"
    apt install -y software-properties-common || die "Failed to install software-properties-common"
fi

if needs_install ansible; then
    echo "🐮 Installing Ansible..."
    add-apt-repository --yes --update ppa:ansible/ansible || die "Failed to add the Ansible PPA"
    apt update || die "Failed to run apt update"
    apt install -y ansible || die "Failed to install Ansible"
fi

# run ansible-pull!
echo "📥 Pulling Ansible config..."
ansible-pull -U https://github.com/ucla-e1-malware/vm-init -i "e1-$playbook," "playbooks/$playbook.yaml"
