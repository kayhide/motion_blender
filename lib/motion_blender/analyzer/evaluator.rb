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
        [parse_arg(@ast)]
      end

      def parse_arg ast
        arg_ast = ast.children[2]
        clean_room = BasicObject.new
        clean_room.instance_eval(arg_ast.loc.expression.source, @file)
      rescue
        exp = ast.loc.expression.source
        raise LoadError, "failed to parse `#{exp}'"
      end
    end
  end
end
