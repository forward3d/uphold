module Uphold
  module Helpers
    module_function

    BUFFER_SIZE = 4_194_304
    TYPES = {
      'gzip' => 'gzip',
      'gz'   => 'gzip',
      'tar'  => 'tar',
      'zip'  => 'zip'
    }

    def decompress(file)
      if compressed?(file)
        extract(file).each do |decompressed_file|
          if compressed?(decompressed_file)
            decompress(decompressed_file)
          else
            yield(decompressed_file)
          end
        end
      else
        yield file
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
      File.join(File.dirname(input_file), File.basename(input_file, '.*')).tap do |output_file|
        open(output_file, 'w:binary') do |output|
          Zlib::GzipReader.open(input_file) do |gz|
            output.write gz.read(BUFFER_SIZE) until gz.eof?
          end
        end
      end
    end

    # be wary of directories and tar long links
    def tar_decompress(input_file, _opts = {})
      files = []
      File.open(input_file) do |input_file_io|
        Gem::Package::TarReader.new(input_file_io) do |tar|
          tar.rewind
          tar.each do |entry|
            files << save_tar_entry(entry, File.dirname(input_file)) if entry.file?
          end
        end
      end
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
      path = File.join(dir, entry.full_name)
      FileUtils.mkdir_p(File.dirname(path))
      path.tap do |filename|
        open(filename, 'w') do |output_file|
          output_file.write entry.read(BUFFER_SIZE) until entry.eof?
        end
      end
    end

  end
end
