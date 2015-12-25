require 'parser/current'
require 'active_support'
require 'active_support/callbacks'

require 'motion_blender/analyzer/source'
require 'motion_blender/analyzer/evaluator'
require 'motion_blender/analyzer/require'

module MotionBlender
  class Analyzer
    class Parser
      include ActiveSupport::Callbacks
      define_callbacks :parse

      attr_reader :file, :evaluators

      def initialize file
        @file = file.to_s
        @evaluators = []
      end

      def parse
        ast = ::Parser::CurrentRuby.parse_file(@file)
        traverse(Source.new(ast: ast)) if ast
        self
      end

      def traverse source
        if require_command?(source)
          evaluate source
        elsif !raketime_block?(source)
          source.children.each { |src| traverse src }
        end
      end

      def evaluate source
        @evaluators << Evaluator.new(source)
        @evaluators.last.run
      end

      def requires
        @evaluators.map(&:requires).flatten
      end

      def last_trace
        @evaluators.last.try :trace
      end

      def require_command? source
        source.type.send? && Require.acceptable?(source.method)
      end

      def raketime_block? source
        source.type.block? &&
          (source.children.first.code == 'MotionBlender.raketime')
      end
    end
  end
end
