module MotionBlender
  class Analyzer
    class Cache
      def dir
        MotionBlender.config.cache_dir
      end

      def fetch file
        return yield unless dir

        file = Pathname.new(file)
        cache = cache_file_for(file)
        if valid_cache?(file, cache)
          read cache
        else
          content = yield
          write cache, content
        end
      rescue YAML::Exception
        if cache.exist?
          cache.delete
          retry
        end
        raise
      end

      def read file
        YAML.load_file file
      end

      def write file, content
        file.dirname.mkpath
        file.write YAML.dump(content)
        content
      end

      def valid_cache? file, cache
        cache.file? && file.mtime < cache.mtime
      end

      def cache_file_for file
        file = file.relative_path_from(Pathname.new('/')) if file.absolute?
        dir.join(file.to_s + '.yml')
      end
    end
  end
end
