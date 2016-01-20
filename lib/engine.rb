module Uphold
  class Engine
    include Logging
    include Command

    def load
      logger.info "Engine starting #{self.class}"
      t1 = Time.now
      process = load_backup
      t2 = Time.now
      delta = t2 - t1
      if process.success?
        logger.info "Engine finished successfully (#{format('%.2f', delta)}s)"
        true
      else
        logger.error "Engine failed! (#{format('%.2f', delta)}s)"
        false
      end
    end

    def load_backup
      fail "Your engine must implement the 'load_backup' method"
    end
  end
end
