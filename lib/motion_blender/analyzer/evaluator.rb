require 'motion_blender/analyzer/require'

module MotionBlender
  class Analyzer
    class Evaluator
      attr_reader :file, :ast, :stack

      def initialize file, ast, stack = [], method = nil
        @file = file
        @ast = ast
        @stack = stack
        @method = method || @ast.children[1]
      end

      def parse_args
        extractor = create_extractor
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
          Evaluator.new(@file, stack.last, stack[0..-2], @method).parse_args
        else
          fail LoadError, err.message
        end
      end

      def recover_from_standard_error err
        if @stack.any?
          Evaluator.new(@file, @stack.last, @stack[0..-2], @method).parse_args
        else
          fail LoadError, err.message
        end
      end

      def create_extractor
        file = @file
        extractor = Evaluator.extractor_for(@method).new
        extractor.instance_eval { @_file = file }
        extractor
      end

      def self.extractor_for method
        @extractor_classes ||= {}
        @extractor_classes[method] ||= Class.new do
          define_method method do |arg|
            req = Require.new(@_file, method, arg)
            unless req.excluded?
              @_args ||= []
              @_args << req
            end
          end
        end
      end
    end
  end
end
