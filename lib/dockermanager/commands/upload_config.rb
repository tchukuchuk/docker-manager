module DockerManager
  module Commands
    class UploadConfig < Base
      def run
        # to avoid scope issue
        conf = config

        on conf.env_host do
          execute(:mkdir, "-p", conf.env_remote_directory)
          env_file = "#{conf.local_deploy_path}/#{conf.env}/.env"
          upload!(env_file, "#{conf.env_remote_directory}/.env") if File.readable?(env_file)
          compose_file = "#{conf.local_docker_path}/docker-compose.server.yml"
          upload!(compose_file, "#{conf.env_remote_directory}/docker-compose.yml") if File.readable?(compose_file)
          local_ssl_path = "#{conf.local_deploy_path}/#{conf.env}/ssl"
          if File.readable?(local_ssl_path)
            execute(:rm, "-fr", "#{conf.env_remote_directory}/ssl")
            upload!("#{conf.local_deploy_path}/#{conf.env}/ssl", "#{conf.env_remote_directory}/ssl", recursive: true)
          else
            local_renew_cert_script = "docker/deploy/#{conf.env}/renew_cert.sh"
            upload!(local_renew_cert_script, "#{conf.env_remote_directory}/renew_cert.sh") if File.readable?(local_renew_cert_script)
          end
        end
      end
    end
  end
end
