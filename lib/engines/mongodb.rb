module Uphold
  module Engines
    class Mongodb < Engine
      def initialize(database:, path:)
        @database = database
        @path = path
      end

      def load_backup
        Dir.chdir(@path) do
          logger.debug "chdir to '#{@path}'"
          run_command("mongorestore --verbose --drop --db uphold #{@database}")
        end
      end
    end
  end
end
