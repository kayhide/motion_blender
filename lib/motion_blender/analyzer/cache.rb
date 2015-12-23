module MotionBlender
  class Analyzer
    class Cache
      attr_reader :file, :hit
      alias_method :hit?, :hit

      def initialize file
        @file = Pathname.new(file)
      end

      def dir
        MotionBlender.config.cache_dir
      end

      def fetch
        return yield unless dir

        @hit = valid?
        if @hit
          read
        else
          content = yield
          write content
        end
      rescue YAML::Exception
        retry if delete
        raise
      end

      def read
        YAML.load_file cache_file
      end

      def write content
        if content.nil?
          delete
        else
          cache_file.dirname.mkpath
          cache_file.write YAML.dump(content)
        end
        content
      end

      def delete
        cache_file.exist? && cache_file.delete
      end

      def valid?
        cache_file.file? && @file.mtime < cache_file.mtime
      end

      def cache_file
        @cache_file ||=
          begin
            path = @file
            path = path.relative_path_from(Pathname.new('/')) if path.absolute?
            dir.join(path.to_s + '.yml')
          end
      end
    end
  end
end
