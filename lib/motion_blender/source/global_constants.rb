module MotionBlender
  class Source
    module GlobalConstants
      def global_constants
        @global_constants ||=
          if root?
            Array.wrap(find_global_constants).flatten.compact.uniq
          else
            root.global_constants
          end
      end

      def find_global_constants
        if like_module?
          if children.first.type.const?
            children.first.code.split('::', 2).first
          end
        else
          children.compact.map(&:find_global_constants)
        end
      end
    end
  end
end
