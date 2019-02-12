module DockerManager
  module Commands
    class Deploy < Base
      def run
        # to avoid scope issue
        conf = config

        run_locally do
          execute("rm -fr #{conf.local_git_tmp_path}")
          execute("git clone -b #{conf.env_git_branch} #{conf.git_repository} #{conf.local_git_tmp_path}")
          execute("touch #{conf.local_git_tmp_path}/.env")
          execute("cp #{conf.local_git_tmp_path}/docker/docker-compose.server.yml #{conf.local_git_tmp_path}")
          # within doesn't work
          change_dir = "cd #{conf.local_git_tmp_path}"
          compose_cmd = "#{change_dir} && TAG=#{conf.env_git_branch} docker-compose -f docker-compose.server.yml"
          execute("#{compose_cmd} build")
          execute("#{change_dir} && docker login -u #{conf.registry_login} -p '#{conf.registry_password}' #{conf.registry_server}")
          execute("#{compose_cmd} push")
        end

        on conf.env_host do
          execute(:mkdir, "-p", "#{conf.env_remote_directory}/data")
          upload!("#{conf.local_docker_path}/docker-compose.server.yml", "#{conf.env_remote_directory}/docker-compose.yml")
          execute("docker login -u #{conf.registry_login} -p '#{conf.registry_password}' #{conf.registry_server}")
          change_dir = "cd #{conf.env_remote_directory}"
          compose_cmd = "#{change_dir} && TAG=#{conf.env_git_branch} docker-compose"
          containers_to_restart = (conf.containers_to_restart || []).join(' ')
          execute("#{compose_cmd} pull -q")
          execute("#{compose_cmd} up -d #{containers_to_restart}")
          execute("docker system prune -f")
        end
      end
    end
  end
end
