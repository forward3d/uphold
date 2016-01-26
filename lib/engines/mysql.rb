module Uphold
  module Engines
    class Mysql < Engine

      def initialize(params)
        super(params)
        @docker_image ||= 'mysql'
        @docker_tag ||= '5.7.10'
        @docker_env ||= ['MYSQL_ALLOW_EMPTY_PASSWORD=yes', "MYSQL_DATABASE=#{@database}"]
        @port ||= 3306
        @sql_file ||= 'MySQL.sql'
      end

      def load_backup(path)
        Dir.chdir(path) do
          run_command("mysql -u root --host=#{container_ip_address} #{@database} < #{@sql_file}")
        end
      end
    end
  end
end
