module Uphold
  module Engines
    class Mongodb < Engine
      def initialize(database:, path:)
        @database = database
        @path = path
      end

      def load
        Dir.chdir(@path) do
          logger.debug "chdir to '#{@path}'"
          process = run_command("mongorestore --verbose --drop --db uphold #{@database}")
          if process.success?
            logger.info 'Database loaded successfully'
            true
          else
            logger.error 'Database did not load successfully'
            false
          end
        end
      end
    end
  end
end
