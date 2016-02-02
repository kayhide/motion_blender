require 'active_support'
require 'active_support/callbacks'

require 'motion_blender/analyzer/cache'
require 'motion_blender/analyzer/evaluator'

module MotionBlender
  class Analyzer
    class Parser
      include ActiveSupport::Callbacks
      define_callbacks :parse

      attr_reader :file, :evaluators, :cache, :referring_constants

      def initialize file
        @file = file.to_s
        @evaluators = []
      end

      def parse
        cached = cache.fetch do
          run_callbacks :parse do
            root = Source.parse_file(@file)
            traverse(root)
            {
              sources: processed_sources.map(&:attributes),
              referring_constants: root.referring_constants
            }
          end
        end
        if cached && cache.hit?
          cached[:sources].each do |attrs|
            evaluate Source.new(attrs)
          end
        end
        @referring_constants = cached[:referring_constants]
        self
      end

      def cache
        @cache ||= Cache.new @file
      end

      def traverse source
        if Collector.requirable?(source)
          evaluate source
        elsif Collector.acceptable?(source)
          source.children.compact.each { |src| traverse src }
        end
      end

      def evaluate source
        @evaluators << Evaluator.new(source)
        @evaluators.last.run
      end

      def requires
        @evaluators.map(&:requires).flatten
      end

      def processed_sources
        @evaluators.select(&:done?).map(&:source)
      end

      def last_trace
        @evaluators.last.try :trace
      end

      def autoloads_with autoloads
        referring_constants.map do |mods, const|
          key =
            mods.length.downto(0)
            .map { |i| [*mods.take(i), const].join('::') }
            .find { |k| autoloads.key?(k) }
          autoloads[key]
        end.flatten.compact
      end

      def dependent_requires opts = {}
        autoloads = opts[:autoloads]
        reqs = requires.reject(&:autoload?)
        reqs += autoloads_with(autoloads) if autoloads
        reqs.uniq(&:file)
      end
    end
  end
end
