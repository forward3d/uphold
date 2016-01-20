module Uphold
  class Transport
    include Logging
    include Compression

    def fetch
      path = fetch_backup
      if path.nil?
        logger.fatal 'Transport failed!'
      else
        logger.info 'Transport finished successfully'
        path
      end
    end

    def fetch_backup
      fail "Your transport must implement the 'fetch' method"
    end
  end
end
