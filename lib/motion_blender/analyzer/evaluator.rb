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
        extractor.instance_eval { @args }
      rescue
        if stack.any?
          Evaluator.new(@file, stack.last, stack[0..-2], @method).parse_args
        else
          exp = @ast.loc.expression.source
          raise LoadError, "failed to parse `#{exp}'"
        end
      end

      def create_extractor
        obj = Object.new
        obj.define_singleton_method @method do |arg|
          @args ||= []
          @args << arg
        end
        obj
      end
    end
  end
end
