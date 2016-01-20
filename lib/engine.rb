module Uphold
  class Engine
    include Logging
    include Command

    def load
      process = load_backup
      if process.success?
        logger.info 'Engine finished successfully'
        true
      else
        logger.error 'Engine failed!'
        false
      end
    end

    def load_backup
      fail "Your engine must implement the 'load_backup' method"
    end
  end
end
