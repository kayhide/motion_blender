require 'motion_blender/interpreters/base'
require 'motion_blender/analyzer/original_finder'

module MotionBlender
  module Interpreters
    class OriginalInterpreter < Base
      interprets :__ORIGINAL__

      def interpret
        OriginalFinder.new(file).find
      end
    end
  end
end
