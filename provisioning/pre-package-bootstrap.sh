mv /home/vagrant/ntp.conf /etc/ntp.conf
service ntp restart
mv /home/vagrant/sources.list /etc/apt/sources.list
apt-get update
apt-get install -y python-software-properties
apt-add-repository ppa:brightbox/ruby-ng
apt-get update
apt-get install -y build-essential git-core zlib1g-dev libssl-dev \
  libreadline-dev libyaml-dev subversion maven2 gradle npm curl rdiff-backup \
  zip ruby2.2 ruby-switch libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev \
  libcurl4-openssl-dev libffi-dev
ruby-switch --set ruby2.2
