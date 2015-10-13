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
  Pathname.new(File.expand_path('../fixtures', __FILE__))
end

def use_lib_dir
  let(:lib_dir) { fixtures_dir.join('lib') }

  before do
    $:.unshift lib_dir
  end

  after do
    $:.delete lib_dir
  end
end
