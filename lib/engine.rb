module Uphold
  class Engine
    include Logging
    
    def recover
      fail "Your engine must implement the 'recover' method"
    end
  end
end
