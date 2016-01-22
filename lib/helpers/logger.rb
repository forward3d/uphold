module Uphold
  require 'logger'

  module Logging
    class << self
      def logger
        @logger ||= Logger.new("| tee /var/log/uphold/#{ENV['UPHOLD_LOG_FILENAME'].nil? ? 'uphold' : ENV['UPHOLD_LOG_FILENAME']}.log")
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

    def touch_state_file(state)
      FileUtils.touch(File.join('/var/log/uphold', ENV['UPHOLD_LOG_FILENAME'] + '_' + state)) unless ENV['UPHOLD_LOG_FILENAME'].nil?
    end
  end
end
