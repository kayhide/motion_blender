require 'active_support'
require 'active_support/callbacks'

module MotionBlender
  class Analyzer
    class Require
      include ActiveSupport::Callbacks
      define_callbacks :require

      attr_accessor :loader, :method, :arg, :trace

      def initialize loader, method, arg
        @loader = loader
        @method = method
        @arg = arg
      end

      def file
        @file ||= resolve_path
      end

      def resolve_path
        path = candidates.find(&:file?)
        fail LoadError, "not found `#{arg}'" unless path
        explicit_relative path
      end

      def candidates
        path =
          if %i(motion_require require_relative).include? method
            Pathname.new(loader).dirname.join(arg)
          else
            Pathname.new(arg)
          end
        dirs = path.relative? && load_path || ['']
        exts = path.extname.empty? ? ['', '.rb'] : ['']
        Enumerator.new do |y|
          dirs.product(exts).each do |dir, ext|
            y << Pathname.new(dir).join("#{path}#{ext}")
          end
        end
      end

      def explicit_relative path
        path.to_s.sub(%r{^(?![\./])}, './')
      end

      def uses_load_path?
        method == :require
      end

      def load_path
        if uses_load_path?
          MotionBlender.config.motion_dirs + $LOAD_PATH
        end
      end

      def match? arg_or_file
        arg == arg_or_file || file == arg_or_file
      end

      def excluded?
        MotionBlender.config.builtin_features.include?(arg) ||
          MotionBlender.config.excepted_files.include?(file)
      end
    end
  end
end
