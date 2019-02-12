module DockerManager
  module Commands
    class DbPull < Base
      def run
        # to avoid scope issue
        conf = config
        remote_dump_file = "#{conf.env_remote_directory}/dump.sql.gz"
        local_dump_file = "#{conf.project_root_path}/tmp/#{File.basename(remote_dump_file)}"

        on conf.env_host do
          execute("docker exec -t #{conf.env_remote_postgres_db_container} bash -c 'PGPASSWORD=$POSTGRES_PASSWORD pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER $POSTGRES_DB --no-acl --no-owner' | gzip - -c --stdout > #{remote_dump_file}")
          download!(remote_dump_file, local_dump_file)
        end

        run_locally do
          execute(:rm, "-f", "#{conf.project_root_path}/tmp/dump.sql")
          execute("gunzip #{local_dump_file}")
          # condition pg_stat_activity.datname = \'#{local_database}\' removed
          execute("docker exec -i #{conf.env_local_postgres_db_container} bash -c 'psql -U $POSTGRES_USER -d $POSTGRES_DB -c \"SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pid <> pg_backend_pid()\"'")
          execute("docker exec -i #{conf.env_local_postgres_db_container} bash -c 'dropdb -U $POSTGRES_USER $POSTGRES_DB'")
          execute("docker exec -i #{conf.env_local_postgres_db_container} bash -c 'createdb -U $POSTGRES_USER $POSTGRES_DB'")
          execute("docker exec -i #{conf.env_local_postgres_db_container} bash -c 'psql -U $POSTGRES_USER -d $POSTGRES_DB' < #{conf.project_root_path}/tmp/dump.sql")
          execute(:rm, "#{conf.project_root_path}/tmp/dump.sql")
        end
      end
    end
  end
end
