require 'motion_blender/collector'

module MotionBlender
  module Interpreters
    class Base
      module ClassMethods
        attr_reader :method

        def interprets method
          @method = method
          Collector.interpreters[method] = self
          Collector.reset_prepared
        end

        def requirable?
          false
        end
      end

      extend ClassMethods

      attr_reader :collector

      def initialize collector
        @collector = collector
      end

      def source
        @source ||= collector.instance_variable_get(:@_source)
      end

      def requires
        @requires ||= collector.instance_variable_get(:@_requires)
      end

      def file
        source.file
      end

      def method
        self.class.method
      end
    end
  end
end
