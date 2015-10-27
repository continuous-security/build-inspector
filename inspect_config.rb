require 'yaml'

class InspectConfig
  CONFIG = '.inspect.yml'

  def initialize
    @config = YAML.load_file(CONFIG)if File.exist? CONFIG
    @config ||= {}
    @config['directories'] ||= {}
    @excluded = @config['directories'].fetch('excluded', [])
    @included = @config['directories'].fetch('included', [])
  end

  def method_missing(sym, *args, &block)
    @config[sym.to_s]
  end

  # Returns a string representing a list of files and directories
  # This string is in rdiff-backup's --include-filelist format
  def filelist
    @excluded.map { |x| "- #{x}" }
             .concat(@included)
             .join("\n")
  end
end
