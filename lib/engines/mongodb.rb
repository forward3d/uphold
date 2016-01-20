module Uphold
  module Engines
    class Mongodb < Engine
      def initialize(database:, path:)
        @database = database
        @path = path
      end

      def load
        logger.info "Starting MongoDB load for '#{@database}'"
        Dir.chdir(@path) do
          logger.debug "chdir to '#{@path}'"
          process = run_command("mongorestore --verbose --drop --db uphold #{@database}")
          if process.success?
            logger.info 'Database loaded successfully'
          else
            logger.error 'Database did not load successfully'
          end
        end
      end
    end
  end
end
