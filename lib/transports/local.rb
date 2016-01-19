module Uphold
  module Transports
    class Local < Transport
      def fetch(path:)
        path
      end
    end
  end
end
