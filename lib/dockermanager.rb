require File.dirname(__FILE__) + '/dockermanager/version'
require File.dirname(__FILE__) + '/dockermanager/config'
require File.dirname(__FILE__) + '/dockermanager/commands/base'
require File.dirname(__FILE__) + '/dockermanager/commands/deploy'
require File.dirname(__FILE__) + '/dockermanager/commands/db_pull'

module DockerManager
  extend self

  def run
    unless File.exist?("./dockermanager.yml")
      puts "dockermanager.yml file not found"
      exit 1
    end
    if ARGV.size != 2
      puts "usage: dockermanager environment [deploy|db_pull]"
      exit 2
    end
    klass = "Commands::#{ARGV[1].split('_').collect(&:capitalize).join}"
    const_get(klass).new(env: ARGV[0], config_file: ARGV[2]).run
  end
end
