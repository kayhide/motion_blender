require 'simplecov'
require 'simplecov-gem-profile'
SimpleCov.start 'gem'

ENV['RUBYMOTION_ENV'] ||= 'test'

require 'pry'
require 'pry-doc'
require 'active_support'
require 'active_support/core_ext'

require 'motion_blender'
require 'motion_blender/config'

Dir[Bundler.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.before do
    MotionBlender.reset_config
    MotionBlender.config.cache_dir = nil
  end
end
