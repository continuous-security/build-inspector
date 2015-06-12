#vag
#git clone git@github.com:nex3/rb-inotify.git

#apt-get update
#apt-get install -y git subversion
#apt-get install -y maven2 gradle npm
apt-get install -y curl rdiff-backup


# Easier to set some things up as vagrant user rather than root
chmod +x "/vagrant/bootstrap_as_vagrant.sh"
su --login vagrant -c "/vagrant/bootstrap_as_vagrant.sh"


# Backup everything as a last step to allow for file comparison when finished
rdiff-backup --include-filelist /vagrant/backup.txt / /backup

#processes before and after, resident stuff
