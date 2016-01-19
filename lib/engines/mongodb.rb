module Uphold
  module Engines
    class Mongodb < Engine
      def initialize(database:, path:)
        @database = database
        @path = path
      end

      def recover
        # do stuff
      end
    end
  end
end
