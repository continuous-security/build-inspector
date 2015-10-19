# This runs as vagrant user, not root!

# Maybe some builds need bower
#npm install -g bower

echo "gem: --no-ri --no-rdoc" >> ~/.gemrc

echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
