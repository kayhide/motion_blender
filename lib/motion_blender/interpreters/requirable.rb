module MotionBlender
  module Interpreters
    module Requirable
      extend ActiveSupport::Concern

      module ClassMethods
        def requirable? source
          source.type.send? && (source.method == method)
        end
      end

      def find_require arg
        return if excluded_arg? arg

        req = Require.new(file, method, arg)
        req.file = resolve_path req.arg
        return if excluded_file? req.file

        req
      end

      def resolve_path arg
        path = candidates(arg).find(&:file?)
        fail LoadError, "not found `#{arg}'" unless path
        explicit_relative path
      end

      private

      def excluded_arg? arg
        MotionBlender.config.builtin_features.include?(arg) ||
          MotionBlender.config.excepted_files.include?(arg)
      end

      def excluded_file? file
        MotionBlender.config.excepted_files.include?(file)
      end

      def explicit_relative path
        path.to_s.sub(%r{^(?![\./])}, './')
      end
    end
  end
end
