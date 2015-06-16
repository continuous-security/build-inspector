#!/usr/bin/env ruby
require 'optparse'
require './vagrant_whisperer'

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

commands = []

# Clone repo
commands << "git clone #{repo} #{VagrantWhisperer::REPO_DIR}"
commands << "cd #{VagrantWhisperer::REPO_DIR}"

# Add repo to backup so we can diff later
commands << 'echo Preparing snapshot ...'
commands << 'rdiff-backup --include-filelist /home/vagrant/snapshot-targets.txt / /backup'

# Begin network monitoring
commands << 'echo "Starting network monitoring ..."'
commands << 'sudo tcpdump -w /evidence/evidence.pcap -i eth0 &disown'

# Record all processes to diff later
commands << 'ps aux --sort=lstart > /evidence/ps-before.txt'

commands << build_cmd

whisperer = VagrantWhisperer.new
whisperer.runCommands(commands)

puts "Should be sleeping for #{options[:duration]} minutes while we wait for build..."
#sleep(options[:duration])

commands.clear
commands << "rdiff-backup --list-changed-since #{options[:duration] + 1}M /backup > /evidence/fs-diff.txt"

# TODO: for each file in rdiff backup, diff it and append into evidence

# TODO: not yet
#commands << "vagrant destroy"

whisperer.runCommands(commands)

# collect /evidence

# parse pcap

# diff ps

# diff fs
