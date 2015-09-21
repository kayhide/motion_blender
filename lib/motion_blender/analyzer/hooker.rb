module MotionBlender
  class Analyzer
    module Hooker
      module_function

      def active?
        !!@active
      end

      def activate
        @active = true
      end

      def deactivate
        @active = false
      end

      def requires
        @requires ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def clear
        requires.clear
      end
    end

    module Hooks
      def require feature
        if Hooker.active?
          super
          src = caller.first.split(':', 2).first
          Hooker.requires[src] << feature
        else
          super
        end
      end
    end
  end
end

Object.send :include, MotionBlender::Analyzer::Hooks
