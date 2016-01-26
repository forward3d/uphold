module Uphold
  module Engines
    class Mongodb < Engine

      def initialize(params)
        super(params)
        @docker_image ||= 'mongo'
        @docker_tag ||= '3.2.1'
        @port ||= 27_017
      end

      def load_backup(path)
        Dir.chdir(path) do
          run_command("mongorestore --verbose --host #{container_ip_address} --port #{@port} --drop --db #{@database} #{@database}")
        end
      end
    end
  end
end
