module Uphold
  module Transports
    class S3 < Transport
      def initialize(params)
        super(params)
        @region = params[:region]
        @access_key_id = params[:access_key_id]
        @secret_access_key = params[:secret_access_key]
        @bucket = params[:bucket]
      end

      def fetch_backup
        s3 = Aws::S3::Client.new(region: @region, access_key_id: @access_key_id, secret_access_key: @secret_access_key)
        matching_prefix = s3.list_objects(bucket: @bucket, max_keys: 10, prefix: @path).contents.collect(&:key)
        matching_file = matching_prefix.find { |s3_file| File.fnmatch(@filename, File.basename(s3_file)) }

        File.open(File.join(@tmpdir, File.basename(matching_file)), 'wb') do |file|
          logger.info "Downloading '#{matching_file}' from S3 bucket #{@bucket}"
          s3.get_object({ bucket: @bucket, key: matching_file }, target: file)
          decompress(file) do |_b|
          end
        end
        File.join(@tmpdir, @folder_within)
      end
    end
  end
end
