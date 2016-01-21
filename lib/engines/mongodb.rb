module Uphold
  module Engines
    class Mongodb < Engine
      def load_backup(path)
        Dir.chdir(path) do
          run_command("mongorestore --verbose --drop --db uphold #{@database}")
        end
      end
    end
  end
end
