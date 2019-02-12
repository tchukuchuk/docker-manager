require File.dirname(__FILE__) + '/dockermanager/version'
require File.dirname(__FILE__) + '/dockermanager/config'
require File.dirname(__FILE__) + '/dockermanager/commands/base'
require File.dirname(__FILE__) + '/dockermanager/commands/deploy'
require File.dirname(__FILE__) + '/dockermanager/commands/db_pull'
require File.dirname(__FILE__) + '/dockermanager/commands/upload_config'

module DockerManager
  extend self

  def run
    if ARGV.size < 2
      puts "usage: dockermanager environment [deploy|db_pull|upload_config] config_file"
      exit 2
    end
    klass = "Commands::#{ARGV[1].split('_').collect(&:capitalize).join}"
    const_get(klass).new(env: ARGV[0], config_file: ARGV[2]).run
  end
end
