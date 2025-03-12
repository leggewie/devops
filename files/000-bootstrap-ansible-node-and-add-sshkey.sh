#!/bin/bash
# bootstrap a Debian/Ubuntu node just far enough to be able to
# manage it via ansible going forward.  Just like ansible itself,
# this script is idempotent so it can be called over and over again
# without ill effect.
#
# 1) install my SSH key
# 2) install sudo and python
# 3) set up a passwordless ansible user

set -e # exit on all errors

# set up my ssh key for ssh login
add_ssh_key () {
  # assign the first parameter to $user using "parameter expansion with error message"
  local user=${1:?ERROR: User name is required}

  if ! id -u "$user" &> /dev/null; then
    echo "ERROR: User $user does not exist."
  else
    sudo -u "$user" bash -c '
      KEY_FILE=$HOME/.ssh/authorized_keys
      SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFp4mGpUoB6N88nWHusqCFoan6a7vCa6PjnQ9/Uv5YGl foss@leggewie.org"

      mkdir -p $(dirname $KEY_FILE)
      touch $KEY_FILE

      # add key only if it isn`t present yet
      grep -q -F "$SSH_KEY" $KEY_FILE 2>/dev/null || echo "$SSH_KEY" >> $KEY_FILE

      # ensure proper file permissions on the keyfile
      chown $user:$user $KEY_FILE $(dirname $KEY_FILE)
      chmod 600 $KEY_FILE
      chmod 700 $(dirname $KEY_FILE)
    ' && echo "ssh key set up successfully for user $user" || \
         echo "Error setting up ssh key for user $user"
  fi
  echo
}

if [ $UID -eq 0 ]; then
  # add SSH key for root user
  add_ssh_key root

  # ansible needs python and sudo to run
  echo "making sure python3 and sudo are installed, this may take a while"
  apt update &> /dev/null
  apt-get -y install python3 sudo &> /dev/null && \
    echo "sudo and python were successfully installed" || \
    echo "ERROR: Something went wrong when installing sudo and python"
  echo

  # add USER ansible and prepare for passwordless sudo access
  if ! id -u "ansible" &> /dev/null; then
    echo "Creating user ansible"
    useradd -m -s /bin/bash ansible
  else
    echo "user ansible already present, only adding to sudoers"
  fi
  if grep -qE "^[@#]includedir /etc/sudoers.d/?$" /etc/sudoers; then
    echo "ansible ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible > /dev/null
    visudo --check --quiet --strict || visudo --check --strict
  else
    echo "ERROR: it appears you are not including /etc/sudoers.d. Aborting here."
    exit 127
  fi
  add_ssh_key ansible
else
  add_ssh_key $(id -un)
fi
