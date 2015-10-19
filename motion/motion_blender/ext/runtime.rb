module MotionBlender
  module Ext
    module Runtime
      def incept _ = nil
      end

      def except _ = nil
      end

      def use_motion_dir _ = nil
      end

      def motion?
        true
      end

      def raketime?
        false
      end

      def runtime?
        true
      end

      def raketime &_
      end

      def runtime &proc
        proc.call
      end
    end
  end

  extend Ext::Runtime
end
