mv /home/vagrant/ntp.conf /etc/ntp.conf
service ntp restart
mv /home/vagrant/sources.list /etc/apt/sources.list
apt-get update
apt-get install -y git subversion
apt-get install -y maven2 gradle npm
apt-get install -y curl rdiff-backup zip
