# This runs as vagrant user, not root!

# Maybe some builds need bower
#npm install -g bower

# Need to import this public key for RVM
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3

# Sometimes the gpg command fails. Try it another way.
curl -#LO https://rvm.io/mpapis.asc && gpg --import mpapis.asc && rm mpapis.asc

curl -sSL https://get.rvm.io | bash -s $1
echo rvm_install_on_use_flag=1 >> /home/vagrant/.rvmrc
source /home/vagrant/.rvm/scripts/rvm
rvm use --install 2.2.1
gem install bundler


echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
