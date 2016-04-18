require 'motion_blender/collector'

module MotionBlender
  class Analyzer
    class Evaluator
      attr_reader :source
      attr_reader :trace, :requires
      attr_reader :dynamic
      alias dynamic? dynamic
      attr_reader :done
      alias done? done

      def initialize source
        @source = source
        @trace = source.to_s
        @requires = []
        @dynamic = false
      end

      def run
        return if @source.evaluated?
        @source.evaluated!

        @requires = Collector.new(@source).collect_requires
        @requires.each do |req|
          req.trace = @trace
        end
        @done = true
        self
      rescue StandardError, ScriptError => err
        recover_from_error err
      end

      private

      def recover_from_error err
        @source = @source.parent
        @source = @source.parent if @source && @source.type.rescue?
        raise LoadError, err.message unless @source
        @dynamic = true
        run
      end
    end
  end
end
