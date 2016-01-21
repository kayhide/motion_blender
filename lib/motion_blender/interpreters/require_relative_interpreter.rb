require 'motion_blender/interpreters/require_interpreter'

module MotionBlender
  module Interpreters
    class RequireRelativeInterpreter < RequireInterpreter
      interprets :require_relative

      def candidates arg
        path = Pathname.new(file).dirname.join(arg)
        exts = path.extname.empty? ? ['', '.rb'] : ['']
        Enumerator.new do |y|
          exts.each do |ext|
            y << Pathname.new("#{path}#{ext}")
          end
        end
      end
    end
  end
end
