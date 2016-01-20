module Uphold
  module Engines
    class Mongodb < Engine
      def initialize(database:, path:)
        @database = database
        @path = path
      end

      def load_backup
        Dir.chdir(@path) do
          run_command("mongorestore --verbose --drop --db uphold #{@database}")
        end
      end
    end
  end
end
