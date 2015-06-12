 #!/usr/bin/env bash

 source /home/vagrant/.rvm/scripts/rvm

 rvm use --install $1

 shift

 if (( $# ))
    then gem install $@
 fi
