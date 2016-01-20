module Uphold
  class Tests
    include Logging
    include Command

    def initialize(tests)
      @tests = tests
    end

    def run
      logger.info 'Tests starting'
      @tests.each do |t|
        process = run_command("ruby tests/#{t}")
        if process.success?
          logger.info 'Tests finished successfully'
          true
        else
          logger.fatal 'Tests did NOT finish successfully'
          false
        end
      end
    end
  end
end
