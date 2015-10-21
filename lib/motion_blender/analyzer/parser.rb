require 'parser/current'
require 'active_support'
require 'active_support/callbacks'

require 'motion_blender/analyzer/evaluator'

module MotionBlender
  class Analyzer
    class Parser
      include ActiveSupport::Callbacks
      define_callbacks :parse

      REQUIREMENT_TOKENS = %i(motion_require require_relative require)

      attr_reader :file, :requires, :last_trace

      def initialize file
        @file = file.to_s
        @requires = []
      end

      def parse
        ast = ::Parser::CurrentRuby.parse(File.read(@file))
        traverse ast if ast
      end

      def traverse ast, stack = []
        if require_command?(ast)
          evaluate ast, stack
        elsif !raketime_block?(ast)
          ast.children
            .select { |node| node.is_a?(::Parser::AST::Node) }
            .each { |node| traverse node, [*stack, ast] }
        end
      end

      def evaluate ast, stack
        @last_trace = trace_for ast
        Evaluator.new(@file, ast, stack).parse_args.each do |req|
          req.trace = @last_trace
          @requires << req
        end
      end

      def require_command? ast
        (ast.type == :send) && REQUIREMENT_TOKENS.include?(ast.children[1])
      end

      def raketime_block? ast
        (ast.type == :block) &&
          (ast.children.first.loc.expression.source == 'MotionBlender.raketime')
      end

      def trace_for ast
        "#{@file}:#{ast.loc.line}:in `#{ast.children[1]}'"
      end
    end
  end
end
