module Uphold
  module Engines
    class Postgresql < Engine

      def initialize(params)
        super(params)
        @docker_image ||= 'postgres'
        @docker_tag ||= '9.5.0'
        @docker_env ||= ["POSTGRES_USER=#{@database}", "POSTGRES_DB=#{@database}"]
        @port ||= 5432
        @sql_file = params[:sql_file] ||  'PostgreSQL.sql'
      end

      def load_backup(path)
        Dir.chdir(path) do
          run_command("psql --no-password --set ON_ERROR_STOP=on --username=#{@database} --host=#{container_ip_address} --port=#{@port} --dbname=#{@database} < #{@sql_file}")
        end
      end
    end
  end
end
