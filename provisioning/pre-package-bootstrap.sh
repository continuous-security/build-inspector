mv /home/vagrant/sources.list /etc/apt/sources.list
service puppet stop
service chef-client stop
apt-add-repository ppa:brightbox/ruby-ng
apt-get update
apt-get install -y build-essential git-core zlib1g-dev libssl-dev \
  libreadline-dev libyaml-dev subversion maven2 gradle npm curl rdiff-backup \
  zip ruby2.2 ruby2.2-dev ruby-switch libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev \
  libcurl4-openssl-dev libffi-dev openjdk-7-jdk
ruby-switch --set ruby2.2
echo "gem: --no-ri --no-rdoc" >> /etc/gemrc
gem install bundler
