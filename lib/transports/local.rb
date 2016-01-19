module Uphold
  module Transports
    class Local < Transport
      def initialize(params)
        @dir = params[:dir]
        @path = params[:path]
        @folder = params[:folder]
      end

      def fetch
        if File.file?(@path)
          tmp_path = File.join(@dir, File.basename(@path))
          FileUtils.cp(@path, tmp_path)
          decompress(tmp_path) do |_b|
          end
          File.join(@dir, @folder)
        else
          logger.error "No file exists at '#{@path}'"
        end
      end

    end
  end
end
