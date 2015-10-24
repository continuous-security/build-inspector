require 'yaml'

class Config
  CONFIG = '.inspect.yml'

  attr_reader :whitelist

  def initialize
    @whitelist, @excluded, @included = [], [], []
    return if !File.exist? CONFIG

    @config = YAML.load_file CONFIG
    @whitelist = @config['whitelist']
    @excluded = @config['directories']['excluded']
    @included = @config['directories']['included']
  end

  # Returns a string representing a list of files and directories
  # This string is in rdiff-backup's --include-filelist format
  def filelist
    @excluded.map { |x| "- #{x}" }
             .concat(@included)
             .join("\n")
  end
end
