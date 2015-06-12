 #!/usr/bin/env bash

# Install as vagrant, and not as root
curl -sSL https://get.rvm.io | su -l vagrant -c "bash -s $1"

# Automatically install any Rubies required
su -l vagrant -c "echo rvm_install_on_use_flag=1 >> /home/vagrant/.rvmrc"
