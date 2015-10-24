set -e
# This runs as vagrant user, not root!

# Maybe some builds need bower
#npm install -g bower

echo "gem: --user-install --no-ri --no-rdoc" >> ~/.gemrc
gem install bundler

echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
