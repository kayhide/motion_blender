require 'parser/current'
require 'pathname'

require 'motion_blender/analyzer/evaluator'
require 'motion_blender/analyzer/require'

module MotionBlender
  class Analyzer
    class Parser
      include ActiveSupport::Callbacks
      define_callbacks :parse

      REQUIREMENT_TOKENS = %i(motion_require require_relative require)

      attr_reader :file, :requires, :last_trace
      attr_accessor :exclude_files

      def initialize file
        @file = file.to_s
        @requires = []
      end

      def parse
        ast = ::Parser::CurrentRuby.parse(File.read(@file))
        traverse ast if ast
      end

      def traverse ast, stack = []
        @exclude_files ||= Set.new
        if require_command?(ast)
          @last_trace = trace_for ast
          Evaluator.new(@file, ast, stack).parse_args.each do |arg|
            req = Require.new(@file, ast.children[1], arg)
            next if @exclude_files.include? req.arg
            next if @exclude_files.include? req.file
            req.trace = @last_trace
            @requires << req
          end
        elsif !raketime_block?(ast)
          ast.children
            .select { |node| node.is_a?(::Parser::AST::Node) }
            .each { |node| traverse node, [*stack, ast] }
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
