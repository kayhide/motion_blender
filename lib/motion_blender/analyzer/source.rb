module MotionBlender
  class Analyzer
    class Source
      attr_reader :code, :file, :line, :parent, :type, :method, :ast
      attr_reader :evaluated
      alias_method :evaluated?, :evaluated

      def initialize attrs = {}
        @evaluated = false
        ast = attrs.delete :ast
        if ast
          @code = ast.loc.expression.try(:source)
          @file = ast.loc.expression.try(:source_buffer).try(:name)
          @line = ast.loc.expression.try(:line)
          @type = ast.type.to_s.inquiry
          @method = @type.send? ? ast.children[1] : nil
          @ast = ast
        end
        attrs.each do |k, v|
          instance_variable_set "@#{k}", v
        end
      end

      def evaluated!
        @evaluated = true
      end

      def children
        @children ||=
          if @ast
            @ast.children.grep(::Parser::AST::Node).map do |ast|
              Source.new(ast: ast, parent: self)
            end
          else
            []
          end
      end

      def attributes
        %w(code file line type method).map do |k|
          [k, instance_variable_get("@#{k}")]
        end.to_h.as_json
      end
    end
  end
end
