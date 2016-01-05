require 'motion_blender/analyzer/source'
require 'motion_blender/analyzer/require'

module MotionBlender
  class Collector
    class << self
      attr_accessor :prepared
      alias_method :prepared?, :prepared

      def interpreters
        @interpreters ||= {}
      end

      def get source
        prepare unless prepared?
        new(source, interpreters)
      end

      def collect_requires collector
        collector.instance_variable_get(:@_requires)
      end

      def prepare
        interpreters.each do |method, _|
          define_method method do |*args, &proc|
            @_interpreters[method].interpret(*args, &proc)
          end
        end
        @prepared = true
      end

      def reset_prepared
        @prepared = false
        @requirable_methods = nil
      end

      def requirable_methods
        @requirable_methods ||=
          interpreters.values.select(&:requirable?).map(&:method)
      end

      def requirable? source
        source.type.send? && requirable_methods.include?(source.method)
      end

      def acceptable? source
        !source.type.block? ||
          (source.children.first.code != 'MotionBlender.raketime')
      end
    end

    def initialize source, interpreters
      @_source = source
      @_interpreters = interpreters.map do |method, interpreter|
        [method, interpreter.new(self)]
      end.to_h
      @_requires = []
    end
  end
end
