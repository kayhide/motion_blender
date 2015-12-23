require 'motion_blender/analyzer/require'
require 'motion_blender/analyzer/original_finder'

module MotionBlender
  class Analyzer
    class Evaluator
      attr_reader :file, :ast, :stack

      def initialize file, ast, stack = []
        @file = file
        @ast = ast
        @stack = stack
      end

      def parse_args
        extractor = Extractor.new(@file)
        extractor.instance_eval(@ast.loc.expression.source, @file)
        extractor.instance_eval { @_args || [] }
      rescue ScriptError => err
        recover_from_script_error err
      rescue StandardError => err
        recover_from_standard_error err
      end

      def recover_from_script_error err
        i = @stack.find_index { |ast| ast.type == :rescue }
        if i && i > 0
          stack = @stack[0..(i - 1)]
          Evaluator.new(@file, stack.last, stack[0..-2]).parse_args
        else
          fail LoadError, err.message
        end
      end

      def recover_from_standard_error err
        if @stack.any?
          Evaluator.new(@file, @stack.last, @stack[0..-2]).parse_args
        else
          fail LoadError, err.message
        end
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
