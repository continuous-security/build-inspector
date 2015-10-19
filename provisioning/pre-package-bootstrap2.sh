# This runs as vagrant user, not root!

# Maybe some builds need bower
#npm install -g bower

echo "gem: --no-ri --no-rdoc --user-install" >> ~/.gemrc
echo -e "PATH=\"\$PATH:/home/vagrant/.gem/ruby/2.2.0/bin\"" >> ~/.bashrc
gem install bundler


echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
