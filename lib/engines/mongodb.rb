module Uphold
  module Engines
    class Mongodb < Engine
      def initialize(database:, path:)
        @database = database
        @path = path
      end

      def recover
        logger.info "Starting recovery"
        Dir.chdir(@path) do
          process = run_command("mongorestore --verbose --drop --db uphold #{@database}")
          if process.success?
            logger.info 'DB restored successfully'
          else
            logger.error 'DB did not restore successfully'
          end
        end
      end
    end
  end
end
