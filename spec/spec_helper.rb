require 'simplecov'
require 'simplecov-gem-profile'
SimpleCov.start 'gem'

ENV['RUBYMOTION_ENV'] ||= 'test'

require 'bundler'
Bundler.require :test

require 'motion_blender'

def fixtures_dir
  Pathname.new(File.expand_path('../fixtures', __FILE__))
end
