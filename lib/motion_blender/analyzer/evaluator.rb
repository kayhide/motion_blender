require 'motion_blender/analyzer/source'
require 'motion_blender/analyzer/require'
require 'motion_blender/analyzer/original_finder'

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
        extractor = Extractor.new(@source.file)
        extractor.instance_eval(@source.code, @source.file, @source.line)
        @requires = extractor.instance_variable_get(:@_args) || []
        @requires.each do |req|
          req.trace = @trace
        end
        self
      rescue ScriptError => err
        recover_from_script_error err
      rescue StandardError => err
        recover_from_standard_error err
      end

      def recover_from_script_error err
        @source = @source.parent while @source && !@source.type.rescue?
        @source &&= @source.parent
        fail LoadError, err.message unless @source
        @dynamic = true
        run
      end

      def recover_from_standard_error err
        @source = @source.parent
        fail LoadError, err.message unless @source
        @dynamic = true
        run
      end

      class Extractor
        def initialize file
          @_file = file
        end

        Require::TOKENS.each do |method|
          define_method method do |arg|
            req = Require.new(@_file, method, arg)
            unless req.excluded?
              @_args ||= []
              @_args << req
            end
          end
        end

        def __ORIGINAL__
          OriginalFinder.new(@_file).find
        end
      end
    end
  end
end
