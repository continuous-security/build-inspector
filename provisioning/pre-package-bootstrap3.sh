# Backup everything as a last step to allow for file comparison when finished
rdiff-backup --include-filelist /home/vagrant/snapshot-targets.txt / /backup

mkdir /evidence
chown vagrant:vagrant /evidence
echo 'all set, rock on!'
