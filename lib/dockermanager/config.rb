module DockerManager
  class Config
    KEYS = {
      env: {
        required: %i[host docker_user remote_directory remote_postgres_db_container local_postgres_db_container]
      },
      registry: {
        required: %i[login password],
        optional: %i[server]
      },
      required: [],
      optional: %i[containers_to_restart]
    }

    attr_reader :env, :config

    def initialize(env:, config_file:)
      self.env = env
      self.config = YAML.load_file(config_file)
    end

    def project_root_path
      return @project_root_path if defined?(@project_root_path)
      if @project_root_path = value(key: :project_root_path, required: false)
        unless Dir.exist?(@project_root_path)
          puts "invalid project_root_path : #{@project_root_path}"
          exit 3
        end
      else
        @project_root_path = "./"
      end
      @project_root_path
    end

    def local_docker_path
      return @local_docker_path if defined?(@local_docker_path)
      @local_docker_path = "#{project_root_path}/docker"
      unless Dir.exist?(@local_docker_path)
        puts "invalid local docker path : #{@local_docker_path}"
        exit 4
      end
      @local_docker_path
    end

    def local_deploy_path
      return @local_deploy_path if defined?(@local_deploy_path)
      @local_deploy_path = "#{local_docker_path}/deploy"
      unless Dir.exist?(@local_deploy_path)
        puts "invalid local deploy path : #{@local_deploy_path}"
        exit 5
      end
      @local_deploy_path
    end

    KEYS.keys.each do |parent_key|
      case parent_key
      when :required, :optional
        KEYS[parent_key].each do |key|
          define_method key do
            value(key: key, required: (parent_key == :required))
          end
        end
      when :env, :registry
        %i[required optional].each do |scope|
          required = (scope == :required)
          (KEYS[parent_key][scope] || []).each do |key|
            define_method "#{parent_key}_#{key}" do
              value(key: key, parent_key: parent_key, required: required)
            end
          end
        end
      end
    end

    private
      attr_writer :env, :config

      def value(key:, parent_key: nil, required:)
        value_ = if parent_key.nil?
          config[key.to_s]
        else
          if parent_key == :env
            config["environments"][env][key.to_s]
          else
            config[parent_key.to_s][key.to_s]
          end
        end
        return value_ unless value_.nil?
        return unless required
        puts "#{[parent_key, key].compact.join('.')} is missing"
        exit 6
      end
  end
end
