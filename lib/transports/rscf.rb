module Uphold
  module Transports
    class Rscf < Transport
      def initialize(params)
        super(params)
        @region = params[:region]
        @username = params[:username]
        @api_key = params[:api_key]
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
        logger.debug "Loading container '#{@path}'."
        container = rscf.directories.new :key => @path

        File.open(File.join(@tmpdir, File.basename(@filename)), 'wb') do |file|
          logger.info "Downloading '#{@filename}' from Rackspace Cloud Files container '#{@path}'."
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
