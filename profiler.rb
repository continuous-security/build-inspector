#!/usr/bin/env ruby
require 'optparse'
require 'yaml'
require './vagrant_whisperer'
require './packet_inspector'

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

repo_url = ARGV[0]
repo_name = repo_url.split('/').last.chomp('.git')
build_cmd = ARGV[1]

commands = []

# Clone repo
commands << "git clone #{repo_url} #{VagrantWhisperer::REPO_DIR}"
commands << "cd #{VagrantWhisperer::REPO_DIR}"

# Add repo to backup so we can diff later
commands << 'echo Preparing file system snapshot ...'
commands << "sudo rdiff-backup --include-filelist #{VagrantWhisperer::HOME}/snapshot-targets.txt / #{VagrantWhisperer::BACKUP_DIR}"

# Record all processes to diff later
commands << "ps --sort=lstart -eott,cmd > #{VagrantWhisperer::EVIDENCE_DIR}/ps-before.txt"

commands << 'echo "Starting network monitoring ..."'
commands << "sudo tcpdump -w #{VagrantWhisperer::EVIDENCE_DIR}/evidence.pcap -i eth0 &disown"

commands << build_cmd

$whisperer = VagrantWhisperer.new
$whisperer.runCommands(commands)

commands.clear
commands << 'pkill tcpdump'
commands << "ps --sort=lstart -eott,cmd > #{VagrantWhisperer::EVIDENCE_DIR}/ps-after.txt"
get_current_mirror = "`sudo rdiff-backup --list-increments #{VagrantWhisperer::BACKUP_DIR} |  awk -F\": \" '$1 == \"Current mirror\" {print $2}'`"
commands << "sudo rdiff-backup --include-filelist #{VagrantWhisperer::HOME}/snapshot-targets.txt --compare-at-time \"#{get_current_mirror}\" / #{VagrantWhisperer::BACKUP_DIR} > #{VagrantWhisperer::EVIDENCE_DIR}/fs-diff.txt"
commands << %Q~ruby -e 'IO.readlines("/evidence/fs-diff.txt").each { |e| puts e; o,f = e.strip.split(": "); puts `diff -u /\#{f} /backup/\#{f}` if o.eql?("changed") && File.exists?("/"+f) && !File.directory?("/"+f)}' > #{VagrantWhisperer::EVIDENCE_DIR}/fs-diff-with-changes.txt~

$whisperer.runCommands(commands)

$whisperer.collectEvidence(filename = repo_name)

KILOBYTE = 1024.0
WHITELIST = 'whitelist.yml'

def whitelist
  YAML.load_file 'whitelist.yml'
end

def prettify(size)
  return size.to_s + 'B' if size < 1000
  (size / KILOBYTE).round(1).to_s + 'K'
end

def print_outgoing_connections
  puts "Downloading pcap file from vagrant image..."
  pcap_file = 'evidence.pcap'
  $whisperer.getFile "#{VagrantWhisperer::EVIDENCE_DIR}/#{pcap_file}"

  vagrant_ip = $whisperer.ip_address
  packet_inspector = PacketInspector.new pcap_file
  outgoing_packets = packet_inspector.packets_from vagrant_ip

  ips_sizes = outgoing_packets.each_with_object(Hash.new(0)) do |packet, memo|
    memo[packet.ip_dst_readable] += packet.size
  end

  dns_responses = packet_inspector.dns_responses
  address_to_name = dns_responses.each_with_object({}) do |name_addresses, memo|
    name = name_addresses.first
    addresses = name_addresses.last
    addresses.each { |address| memo[address.to_s] = name }
  end

  puts "The following hostnames were reached during the build process:"

  ips_sizes.each do |ip, size|
    host = address_to_name.fetch(ip, ip)
    next if whitelist.include? host
    name_ip = "#{host} (#{ip})".ljust(60)
    puts "  #{name_ip} #{prettify(size).rjust(10)}"
  end
end

print_outgoing_connections

# diff ps

# diff fs

# TODO: not yet, maybe make optional
#commands << "vagrant destroy"
