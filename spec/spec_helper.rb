require 'simplecov'
require 'simplecov-gem-profile'
SimpleCov.start 'gem'

ENV['RUBYMOTION_ENV'] ||= 'test'

require 'pry'
require 'pry-doc'
require 'active_support'
require 'active_support/core_ext'

require 'motion_blender'

def fixtures_dir
  Bundler.root.join('spec/fixtures')
end

def use_lib_dir
  let(:lib_dir) { fixtures_dir.join('lib') }

  before do
    $:.unshift lib_dir.to_s
  end

  after do
    $:.delete lib_dir.to_s
  end
end

RSpec.configure do |config|
  config.before do
    MotionBlender.reset_config
  end
end
