module MotionBlender
  class Source
    module ReferringConstants
      def referring_constants
        @referring_constants ||=
          begin
            child_constants =
              children.map(&:referring_constants).inject(&:+).to_a
            if referring_constant?
              child_constants + [[wrapping_modules.map(&:last), code]]
            else
              child_constants.dup
            end
          end
      end

      def referring_constant?
        type.const?
      end
    end
  end
end
