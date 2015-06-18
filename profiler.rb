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
commands << "sudo rdiff-backup --include-filelist #{VagrantWhisperer::HOME}/snapshot-targets.txt / #{VagrantWhisperer::BACKUP_DIR}"

# Record all processes to diff later
commands << "ps --sort=lstart -eott,cmd > #{VagrantWhisperer::EVIDENCE_DIR}/ps-before.txt"

commands << 'echo "Starting network monitoring ..."'
commands << "sudo tcpdump -w #{VagrantWhisperer::EVIDENCE_DIR}/evidence.pcap -i eth0 &disown"

commands << build_cmd

whisperer = VagrantWhisperer.new
whisperer.runCommands(commands)

puts "Should be sleeping for #{options[:duration]} minutes while we wait for build..."
#sleep(options[:duration])

commands.clear
commands << 'pkill tcpdump'
commands << "ps --sort=lstart -eott,cmd > #{VagrantWhisperer::EVIDENCE_DIR}/ps-after.txt"
get_current_mirror = "`sudo rdiff-backup --list-increments /backup |  awk -F\": \" '$1 == \"Current mirror\" {print $2}'`"
commands << "sudo rdiff-backup --include-filelist #{VagrantWhisperer::HOME}/snapshot-targets.txt --compare-at-time \"#{get_current_mirror}\" / #{VagrantWhisperer::BACKUP_DIR} > #{VagrantWhisperer::EVIDENCE_DIR}/fs-diff.txt"
commands << %Q~ruby -e 'IO.readlines("/evidence/fs-diff.txt").each { |e| puts e; o,f = e.strip.split(": "); puts `diff -u /\#{f} /backup/\#{f}` if o.eql?("changed") && File.exists?("/"+f) && !File.directory?("/"+f)}' > #{VagrantWhisperer::EVIDENCE_DIR}/fs-diff-with-changes.txt~

whisperer.runCommands(commands)

whisperer.collectEvidence

# parse pcap

# diff ps

# diff fs

# TODO: not yet, maybe make optional
#commands << "vagrant destroy"
