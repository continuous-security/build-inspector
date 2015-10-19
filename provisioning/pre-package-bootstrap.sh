mv /home/vagrant/ntp.conf /etc/ntp.conf
service ntp restart
mv /home/vagrant/sources.list /etc/apt/sources.list
apt-get update
apt-get install -y python-software-properties
apt-add-repository ppa:brightbox/ruby-ng
apt-get update
apt-get install -y git subversion maven2 gradle npm curl rdiff-backup zip ruby2.2-dev ruby-switch
ruby-switch --set ruby2.2
