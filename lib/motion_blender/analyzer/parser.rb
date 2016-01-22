require 'active_support'
require 'active_support/callbacks'

require 'motion_blender/analyzer/cache'
require 'motion_blender/analyzer/evaluator'

module MotionBlender
  class Analyzer
    class Parser
      include ActiveSupport::Callbacks
      define_callbacks :parse

      attr_reader :file, :evaluators, :cache

      def initialize file
        @file = file.to_s
        @evaluators = []
      end

      def parse
        srcs = cache.fetch do
          run_callbacks :parse do
            traverse(Source.parse_file(@file))
            @evaluators.select(&:done?).map(&:source).map(&:attributes)
          end
        end
        if srcs && cache.hit?
          srcs.each do |attrs|
            evaluate Source.new(attrs)
          end
        end
        self
      end

      def cache
        @cache ||= Cache.new @file
      end

      def traverse source
        if Collector.requirable?(source)
          evaluate source
        elsif Collector.acceptable?(source)
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
    end
  end
end
