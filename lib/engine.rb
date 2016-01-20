module Uphold
  class Engine
    include Logging
    include Command

    def load
      fail "Your engine must implement the 'load' method"
    end
  end
end
