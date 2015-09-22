# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'motion_blender/version'

Gem::Specification.new do |spec|
  spec.name          = 'motion_blender'
  spec.version       = MotionBlender::VERSION
  spec.authors       = ['kayhide']
  spec.email         = ['kayhide@gmail.com']

  spec.summary       = 'MotionBlender loads ruby gems for RubyMotion'
  spec.description   = 'MotionBlender loads ruby gems for RubyMotion'
  spec.homepage      = 'https://github.com/kayhide/motion_blender'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'parser'
  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'fuubar'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-doc'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-gem-profile'
end
