#!/usr/bin/env ruby
require 'optparse'

options = {
  :duration => 15,
}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage #{File.basename($0)} [options] <git repo URL> <build command>"
  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end

  opts.on('-d', '--duration #', Integer,
    "Wait this long after building before stopping, in minutes, default=#{options[:duration]}") do |duration|
    options[:duration] = duration * 60
  end
end

optparse.parse!

if ARGV.size < 2
    puts "Must specifiy a repo URL and a build command"
    puts optparse.help
    exit -1
end

repo = ARGV[0]
build_cmd = ARGV[1]

exit 0

unless options.has_key?(:repo_url) || options.has_key?(:repo_path)
    puts "Must specifiy either a repo URL or path"
    puts optparse.help
    exit(-1)
end

if options.has_key?(:repo_url) && options.has_key?(:repo_path)
    puts "Must specifiy either a repo URL or path, not both"
    puts optparse.help
    exit(-1)
end

commands = []
repo_dir = '/home/vagrant/repo'
if options.has_key?(:repo_path)
    # TODO: unpack repo to known directory
    puts "Repo path is unsupported."
    puts optparse.help
    exit(-1)
else
    # Clone repo
    # TODO: determine if git or svn
    commands << "git clone #{options[:repo_url]} #{repo_dir}"
end
commands << "cd #{repo_dir}"

# Add repo to backup so we can diff later
commands << 'echo "Preparing snapshot ..."'
commands << 'rdiff-backup --include-filelist /vagrant/backup.txt / /backup'

# Begin network monitoring
commands << 'echo "Starting network monitoring ..."'
commands << 'sudo tcpdump -w /vagrant/evidence/evidence.pcap -i eth0 &disown'

# Record all processes to diff later
commands << 'ps aux --sort=lstart > /vagrant/evidence-ps-before.txt'

if options.has_key?(:build_cmd)
    comands << options[:build_cmd]
else
    commands << "cp /vagrant/autobuild.sh ."
    commands << "chmod +x autobuild.sh"
    commands << "./autobuild.sh"
end


puts commands.join(';')

#sleep(options[:duration])
#wait until timeout

#collect evidence (already in vagrant dir)

#parse evidence into report

#vagrant destroy
