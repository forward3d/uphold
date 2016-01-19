module Uphold
  class Transport
    def fetch
      fail "Your transport must implement the 'fetch' method"
    end
  end
end
