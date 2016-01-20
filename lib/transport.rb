module Uphold
  class Transport
    include Logging
    include Compression

    def fetch
      fail "Your transport must implement the 'fetch' method"
    end
  end
end
