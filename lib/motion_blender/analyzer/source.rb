module MotionBlender
  class Analyzer
    class Source
      attr_accessor :code, :file, :line, :parent, :type, :method

      def initialize attrs = {}
        ast = attrs.delete :ast
        if ast
          @code = ast.loc.expression.source
          @file = ast.loc.expression.source_buffer.name
          @line = ast.loc.expression.line
          @type = ast.type
          @method = (ast.type == :send) ? ast.children[1] : nil
        end
        attrs.each do |k, v|
          send "#{k}=", v
        end
      end
    end
  end
end
