require 'sshkit'
require 'sshkit/dsl'
require 'yaml'

module DockerManager
  module Commands
    class Base
      include SSHKit::DSL

      def initialize(env:, config_file: )
        self.config = Config.new(
          env: env,
          config_file: (config_file || "./dockermanager.yml")
        )
        init_sshkit
      end

      def run
        raise "must be implemented"
      end

      private
        attr_accessor :config

        def init_sshkit
          SSHKit.config.output_verbosity = Logger::DEBUG
          SSHKit::Backend::Netssh.configure do |ssh|
            ssh.ssh_options = {
              user: config.env_docker_user,
              auth_methods: %w[publickey]
            }
          end
        end
    end
  end
end
