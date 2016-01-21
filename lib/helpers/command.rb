module Uphold
  module Command
    module_function

    require 'open3'

    def run_command(cmd, log_command = nil)
      logger.debug "Running command '#{cmd}'"
      log_command ||= "#{cmd.split(' ')[0]}"
      Open3.popen3(cmd) do |_stdin, stdout, stderr, thread|
        # read each stream from a new thread
        { out: stdout, err: stderr }.each do |key, stream|
          Thread.new do
            until (line = stream.gets).nil? do
              # yield the block depending on the stream
              if key == :out
                logger.debug(log_command) { line.chomp } unless line.nil?
              else
                logger.error(log_command) { line.chomp } unless line.nil?
              end
            end
          end
        end

        thread.join # don't exit until the external process is done
        return thread.value
      end
    end
  end
end
