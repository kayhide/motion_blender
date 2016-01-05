require 'motion_blender/interpreters/base'

module MotionBlender
  module Interpreters
    class RequireInterpreter < Base
      interprets :require

      def interpret arg
        req = Require.new(file, method, arg)
        requires << req unless req.excluded?
      end
    end
  end
end
