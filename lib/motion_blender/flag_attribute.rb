module MotionBlender
  module FlagAttribute
    extend ActiveSupport::Concern

    module ClassMethods
      def flag_attribute *args
        args.each do |attr|
          define_method "#{attr}?" do
            !!instance_variable_get("@#{attr}")
          end

          define_method "#{attr}!" do
            instance_variable_set "@#{attr}", true
          end

          define_method "reset_#{attr}!" do
            instance_variable_set "@#{attr}", false
          end
        end
      end
    end
  end
end
