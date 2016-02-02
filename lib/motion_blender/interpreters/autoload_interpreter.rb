require 'motion_blender/interpreters/require_interpreter'

module MotionBlender
  module Interpreters
    class AutoloadInterpreter < RequireInterpreter
      interprets :autoload

      def interpret const_name, arg
        req = super arg
        req.autoload_const_name =
          if object.is_a? Module
            [*object.name.sub(/^#<.+?>::/, ''), const_name].join('::')
          else
            const_name.to_s
          end
      end
    end

    class ModuleAutoloadInterpreter < AutoloadInterpreter
      interprets :autoload, receiver: Module
    end
  end
end
