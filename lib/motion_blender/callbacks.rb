require 'motion_blender/analyzer'

module MotionBlender
  module Callbacks
    def on_parse file = nil, &proc
      filters = {}
      filters[:if] = -> { self.file == file } if file
      Analyzer::Parser.set_callback(:parse, filters, &proc)
    end

    def on_require file = nil, &proc
      filters = {}
      filters[:if] = -> { match? file } if file
      Analyzer::Require.set_callback(:require, filters, &proc)
    end
  end

  extend Callbacks
end
