require 'motion_blender/interpreters/base'

module MotionBlender
  module Interpreters
    class RequireInterpreter < Base
      interprets :require, requirable: true

      def interpret arg
        req = Analyzer::Require.new(file, method, arg)
        requires << req unless req.excluded?
      end
    end
  end
end
