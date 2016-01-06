require 'motion_blender/collector'

module MotionBlender
  class Analyzer
    class Evaluator
      attr_reader :source
      attr_reader :trace, :requires
      attr_reader :dynamic
      alias_method :dynamic?, :dynamic

      def initialize source
        @source = source
        @trace = "#{source.file}:#{source.line}:in `#{source.method}'"
        @requires = []
        @dynamic = false
      end

      def run
        return if @source.evaluated?
        @source.evaluated!

        @requires = Collector.collect_requires(@source)
        @requires.each do |req|
          req.trace = @trace
        end
        self
      rescue StandardError, ScriptError => err
        recover_from_error err
      end

      def recover_from_error err
        @source = @source.parent
        @source = @source.parent if @source && @source.type.rescue?
        fail LoadError, err.message unless @source
        @dynamic = true
        run
      end
    end
  end
end
