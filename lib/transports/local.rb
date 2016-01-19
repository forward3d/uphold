module Uphold
  module Transports
    class Local < Transport
      def initialize(path:)
        @path = path
      end

      def fetch
        @path
      end
    end
  end
end
