module Uphold
  require 'logger'

  module Logging
    class << self
      def logger
        @logger ||= Logger.new($stdout)
      end

      def logger=(logger)
        @logger = logger
      end
    end

    # Addition
    def self.included(base)
      class << base
        def logger
          Logging.logger
        end
      end
    end

    def logger
      Logging.logger
    end
  end
end
