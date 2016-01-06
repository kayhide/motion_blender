require 'motion_blender/interpreters/require_interpreter'

module MotionBlender
  module Interpreters
    class AutoloadInterpreter < RequireInterpreter
      interprets :autoload

      def interpret _, arg
        find_require(arg) do |req|
          requires << req
        end
      end
    end

    class ModuleAutoloadInterpreter < AutoloadInterpreter
      interprets :autoload, receiver: Module
    end
  end
end
