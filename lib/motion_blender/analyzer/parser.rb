require 'parser/current'
require 'pathname'

require 'motion_blender/analyzer/evaluator'

module MotionBlender
  class Analyzer
    class Parser
      REQUIREMENT_TOKENS = %i(motion_require require_relative require)

      Require = Struct.new(:loader, :method, :arg, :file, :trace)

      attr_reader :file, :requires, :last_trace

      def initialize file
        @file = file.to_s
        @requires = []
      end

      def parse
        ast = ::Parser::CurrentRuby.parse(File.read(@file))
        traverse ast
      end

      def traverse ast, stack = []
        if ast && ast.type == :send && require_command?(ast)
          @last_trace = trace_for ast
          Evaluator.new(@file, ast, stack).parse_args.each do |arg|
            req = Require.new(@file, ast.children[1], arg)
            req.file = resolve_path req.method, req.arg
            req.trace = @last_trace
            @requires << req
          end
        elsif ast
          ast.children
            .select { |node| node.is_a?(::Parser::AST::Node) }
            .each { |node| traverse node, stack + [ast] }
        end
      end

      def require_command? ast
        REQUIREMENT_TOKENS.include?(ast.children[1])
      end

      def trace_for ast
        "#{@file}:#{ast.loc.line}:in `#{ast.children[1]}'"
      end

      def resolve_path method, arg
        if %i(motion_require require_relative).include? method
          arg = Pathname.new(@file).dirname.join(arg).to_s
        end
        path = candidates_for(arg, method == :require).find(&:file?)
        fail LoadError, "not found `#{arg}'" unless path
        explicit_relative path
      end

      def candidates_for feature, uses_load_path
        path = Pathname.new(feature)
        dirs = (uses_load_path && path.relative?) ? $LOAD_PATH : ['']
        exts = path.extname.empty? ? ['', '.rb'] : ['']
        Enumerator.new do |y|
          dirs.product(exts).each do |dir, ext|
            y << Pathname.new(dir).join("#{path}#{ext}")
          end
        end
      end

      def explicit_relative path
        path.to_s.sub(%r{^(?![\./])}, './')
      end
    end
  end
end
