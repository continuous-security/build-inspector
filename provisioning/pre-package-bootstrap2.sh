# This runs as vagrant user, not root!

# Maybe some builds need bower
#npm install -g bower

gem install bundler


echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
