module MotionBlender
  class Source
    module WrappingModules
      def wrapping_modules
        @wrapping_modules ||=
          [*parent.try(:wrapping_modules), parent_module].compact
      end

      def parent_module
        if module_content? || class_content?
          [parent.type.to_s, parent.children.first.code]
        end
      end

      def module_content?
        parent && parent.type.module? && (parent.children[1] == self)
      end

      def class_content?
        parent && parent.type.class? && (parent.children[2] == self)
      end
    end
  end
end
