module Uphold
  class Transport
    include Logging
    
    def fetch
      fail "Your transport must implement the 'fetch' method"
    end
  end
end
