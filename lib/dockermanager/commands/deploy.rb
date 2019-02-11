module DockerManager
  module Commands
    class Deploy < Base
      def run
        # to avoid scope issue
        git_repository = config.git_repository
        env = config.env
        local_git_tmp_path = config.local_git_tmp_path
        project_root_path = config.project_root_path
        local_docker_path = config.local_docker_path
        local_deploy_path = config.local_deploy_path
        registry_login = config.registry_login
        registry_password = config.registry_password
        registry_server = config.registry_server
        env_git_branch = config.env_git_branch
        env_remote_directory = config.env_remote_directory
        containers_to_restart = (config.containers_to_restart || []).join(' ')
        run_locally do
          execute("rm -fr #{local_git_tmp_path}")
          execute("git clone -b #{env_git_branch} #{git_repository} #{local_git_tmp_path}")
          execute("cp #{local_deploy_path}/#{env}/.env #{local_git_tmp_path}/.env")
          execute("cp #{local_docker_path}/docker-compose.server.yml #{local_git_tmp_path}")
          # within doesn't work
          execute("cd #{local_git_tmp_path} && TAG=#{env_git_branch} docker-compose -f docker-compose.server.yml build")
          execute("cd #{local_git_tmp_path} && docker login -u #{registry_login} -p '#{registry_password}' #{registry_server}")
          execute("cd #{local_git_tmp_path} && TAG=#{env_git_branch} docker-compose -f docker-compose.server.yml push")
        end
        on config.env_host do
          execute(:mkdir, "-p", "#{env_remote_directory}/data")
          upload!("#{local_deploy_path}/#{env}/.env", "#{env_remote_directory}/.env")
          upload!("#{local_docker_path}/docker-compose.server.yml", "#{env_remote_directory}/docker-compose.yml")
          local_ssl_path = "#{local_deploy_path}/#{env}/ssl"
          if File.readable?(local_ssl_path)
            execute(:rm, "-fr", "#{env_remote_directory}/ssl")
            upload!("#{local_deploy_path}/#{env}/ssl", "#{env_remote_directory}/ssl", recursive: true)
          else
            local_renew_cert_script = "docker/deploy/#{env}/renew_cert.sh"
            upload!(local_renew_cert_script, "#{env_remote_directory}/renew_cert.sh") if File.readable?(local_renew_cert_script)
          end
          execute("docker login -u #{registry_login} -p '#{registry_password}' #{registry_server}")
          execute("cd #{env_remote_directory} && TAG=#{env_git_branch} docker-compose pull -q")
          execute("cd #{env_remote_directory} && TAG=#{env_git_branch} docker-compose up -d #{containers_to_restart}")
          execute("docker system prune -f")
        end
      end
    end
  end
end
