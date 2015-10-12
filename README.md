# MotionBlender [![Build Status](https://travis-ci.org/kayhide/motion_blender.svg?branch=master)](https://travis-ci.org/kayhide/motion_blender)

MotionBlender enables to:

- require *Ruby* files (must be RubyMotion-compatible) from RubyMotion files
- require RubyMotion files from RubyMotion files as well

and then:

- add required files to `app.files`
- resolve dependencies following require tree and put it to `app.files_dependencies`

This is a sccessor of [motion-require](https://github.com/clayallsopp/motion-require) and [MotionBundler](https://github.com/archan937/motion-bundler).

*motion-require* is to resolve dependencies between RubyMotion files with `motion_require` method.
This is only for RubyMotion files and not for using Ruby gems.

*MotionBundler* aims for using Ruby gems from RubyMotion.
This is good for making an application but not for making a gem, because it requires to setup your application Gemfile explicitly.


So, MotionBlender is good for making RubyMotion-compatible gem which depends on other RubyMotion-compatible gems.

I made a fork of MotionSupport which is based on MotionBlender:

- [motion_blender-support](https://github.com/kayhide/motion_blender-support)

This is ready to use to make RubyMotion-compatible gems.

## Installation

### When making a gem

Add a dependency:

```ruby
# in .gemspec file

Gem::Specification.new do |spec|
  # ...
  spec.add_runtime_dependency "motion_blender"
  # ...
end
```

### When making an application

Add this line to your application's Gemfile:

```ruby
gem 'motion_blender'
```

## Usage

Add RubyMotion-compatible gem into your project (may be an application or a gem).

And just call `require` from anywhare:

```ruby
require 'rubymotion_conpatible_gem'

# your code goes on...
```

Writing a gem (*motion_hoge*), this idiom is handy:

```ruby
# in lib/motion_hoge.rb
require 'motion_blender'
MotionBlender.add __FILE__

require 'motion_hoge/simsim'
require 'motion_hoge/mishmish'
require 'motion_hoge/version'
# ...
```

This makes an app or a gem which depends on *motion_hoge* to load functionalities properly, even if it is compile-time.

As a default, `motion_blender` lib files themselves are excluded for analyzing.
So don't worry about requiring `motion_blender` in compile target files.

### Limitation

Currently, `require` has some limitation because of the way how to analyze the code.

The argument must be a string or an eval-able expression:

```ruby
# Good
require 'something'
require File.join('path', 'to', 'feature')
require File.expand_path('../otherthing', __FILE__) # __FILE__ works properly
```

Wrapped in outer loop, works fine:

```ruby
# Good
Dir.glob('lib/**/*.rb').each { |path| require path }
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }
```

Required Files must exist:

```ruby
# Bad
begin
  require 'may_not_exist'
rescue LoadError
  require 'alternative'
end
```

## How does it work?

In the RubyMotion application's Rakefile, `motion_blender` is to be required, typically via `Bundler.require`.
Then it hooks `build` tasks.
You can hit `rake -P` and see `motion_blender:analyze` task is hooked.

At the analyze task, MotionBlender runs analyzer on all `Motion::Project::Config#files`.
It uses [parser](https://github.com/whitequark/parser) and follows all `require` and `require_relative`.
After that, add the newly encountered files to the head of `Motion::Project::Config#files` and put file dependencies to `Motion::Project::Config#dependencies`.

When compiling, `require` and `require_relative` is overwritten as noop.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kayhide/motion_blender. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

