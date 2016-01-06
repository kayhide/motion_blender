require 'motion_blender/collector'

module MotionBlender
  module Interpreters
    class Base
      class << self
        attr_reader :method, :receiver

        def interprets method, options = {}
          @method = method
          @receiver = options[:receiver] || Object
          Collector.register self
        end

        def key
          [@receiver, @method]
        end

        def requirable? _
          false
        end
      end

      attr_reader :collector
      attr_accessor :object
      delegate :method, :receiver, to: :class
      delegate :source, :requires, to: :collector
      delegate :file, to: :source

      def initialize collector
        @collector = collector
      end
    end
  end
end
