module Uphold
  module Transports
    class Rscf < Transport
      def initialize(params)
        super(params)
        @region = params[:region]
        @username = params[:username]
        @api_key = params[:api_key]
        @container = params[:container]
      end

      def fetch_backup
        logger.debug "Connecting to Rackspace Cloud Files region #{@region} as '#{@username}'."
        rscf = Fog::Storage.new({
            :provider            => 'Rackspace',
            :rackspace_username  => @username,
            :rackspace_api_key   => @api_key,
            :rackspace_region    => @region,
            :connection_options  => {
                # Rackspace's endpoint has a Thawte Premium Server CA which was removed from
                # Debian's ca-certificates package, causing verify to fail if enabled.
                :ssl_verify_peer => false
            }
        })
        logger.debug "Loading container '#{@container}'."
        container = rscf.directories.new :key => @container

        File.open(File.join(@tmpdir, File.basename(@filename)), 'wb') do |file|
          unless @path.blank?
            @filename = "#{@path}/#{@filename}"
          end
          logger.info "Downloading '#{@filename}' from Rackspace Cloud Files container '#{@container}'."
          container.files.get(@filename) do | data, remaining, content_length |
            file.syswrite data
          end
          decompress(file) do |_b|
          end
        end
        File.join(@tmpdir, @folder_within)
      end
    end
  end
end
