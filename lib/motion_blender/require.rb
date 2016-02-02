require 'active_support'
require 'active_support/callbacks'

module MotionBlender
  class Require
    include ActiveSupport::Callbacks
    define_callbacks :require

    attr_reader :loader, :method, :arg
    attr_accessor :trace, :file, :autoload_const_name

    def initialize loader, method, arg
      @loader = loader
      @method = method
      @arg = arg
    end

    def match? arg_or_file
      [arg, file].compact.include?(arg_or_file)
    end

    def autoload?
      method == :autoload
    end
  end
end
