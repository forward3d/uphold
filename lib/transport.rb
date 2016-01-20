module Uphold
  class Transport
    include Logging
    include Compression

    attr_reader :tmpdir

    def initialize(params)
      @tmpdir = Dir.mktmpdir('uphold')
      @path = params[:path]
      @filename = params[:filename]
      @folder_within = params[:folder_within]

      @date_format = params[:date_format] || '%Y-%m-%d'
      @date_offset = params[:date_offset] || 0
      @path.gsub!('{date}', (Date.today - @date_offset).strftime(@date_format))
      @filename.gsub!('{date}', (Date.today - @date_offset).strftime(@date_format))
    end

    def fetch
      logger.info "Transport starting #{self.class.to_s}"
      logger.debug "Temporary directory '#{@tmpdir}'"
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
