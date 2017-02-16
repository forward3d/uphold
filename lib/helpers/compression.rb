module Uphold
  module Compression
    module_function

    BUFFER_SIZE = 4_194_304
    TYPES = {
      'gzip' => 'gzip',
      'gz'   => 'gzip',
      'tar'  => 'tar',
      'zip'  => 'zip'
    }

    def decompress(file, &blk)
      if compressed?(file)
        logger.debug "Decompressing '#{File.basename(file)}'"
        extract(file).each do |decompressed_file|
          compressed?(decompressed_file) ? decompress(decompressed_file, &blk) : blk.call(decompressed_file)
        end
      else
        blk.call(file)
      end
    end

    def compressed?(file)
      identify(file)
    end

    private

    def extract(file, opts = {})
      type = opts.delete(:type) || opts.delete('type') || identify(file)
      fail("Could not decompress #{File.basename(file)}. Please add a handler to handle files of type: #{type}.") unless respond_to?("#{type}_decompress", true)
      files = send("#{type}_decompress", file, opts)
      [files].flatten
    end

    def identify(file)
      type = File.extname(file)[1..-1]
      TYPES[type]
    end

    def zip_decompress(input_file, opts = {})
      files = []
      Zip::InputStream.open(input_file) do |zip|
        while (entry = zip.get_next_entry)
          files << save_zip_entry(zip, entry, File.dirname(input_file), opts)
        end
      end
      files
    end

    def gzip_decompress(input_file, _opts = {})
      blocksize_to_read = 10240000
      File.join(File.dirname(input_file), File.basename(input_file, '.*')).tap do |output_file|
        open(output_file, 'w:binary') do |output|
          Zlib::GzipReader.open(input_file) do |gz|
            while buffer = gz.read(blocksize_to_read)
              output.write buffer until gz.eof?
            end
          end
        end
      end
    end
    # be wary of directories and tar long links
    def tar_decompress(input_file, _opts = {})
      logger.info "Input file is #{File.basename(input_file)}"
      logger.debug "Files in #{@tmpdir}/#{Dir.entries(@tmpdir)}"
      logger.debug "tar xfv #{@tmpdir}/#{File.basename(input_file)}. -C #{@tmpdir}"
      if ::File.exists?("#{@tmpdir}/#{File.basename(input_file,".tar")}/databases/MySQL.sql")
	logger.info "Already extracted"
	else	
      system("tar xfv #{@tmpdir}/#{File.basename(input_file)} -C #{@tmpdir}")
      end
      files = []
      files << "#{@tmpdir}/#{File.basename(input_file,".tar")}/databases/MySQL.sql"
      files
    end

    def save_zip_entry(zip, entry, dir, opts)
      File.join(dir, entry.name).tap do |filename|
        open(filename, 'w') do |output_file|
          if opts[:zip_encoding]
            output_file.write zip.read(BUFFER_SIZE).encode(opts[:zip_encoding], undef: :replace, replace: '') until zip.eof?
          else
            output_file.write zip.read(BUFFER_SIZE) until zip.eof?
          end
        end
      end
    end

    def save_tar_entry(entry, dir)
      File.join(dir, entry.full_name).tap do |filename|
        FileUtils.mkdir_p(File.dirname(filename))
        open(filename, 'w') do |output_file|
          output_file.write entry.read(BUFFER_SIZE) until entry.eof?
        end
      end
    end

  end
end
