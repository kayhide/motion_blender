require 'motion_blender/version'
require 'motion_blender/analyzer'
require 'motion_blender/rake_tasks'

module MotionBlender
  module_function

  def analyze
    Motion::Project::App.setup do |app|
      analyzer = Analyzer.new
      analyzer.exclude_files += Dir[File.expand_path('../**/*.rb', __FILE__)]
      analyzer.exclude_files += builtin_features
      app.files.flatten.each do |file|
        analyzer.analyze file
      end

      if analyzer.files.any?
        app.exclude_from_detect_dependencies += [ext_file, *analyzer.files]
        app.files = [ext_file, *(analyzer.files - app.files), *app.files]
        app.files_dependencies analyzer.dependencies
      end
    end
  end

  def add file = nil
    return unless motion?

    file ||= caller.first.split(':', 2).first
    Motion::Project::App.setup do |app|
      app.files.unshift file
    end
  end

  def use_motion_dir dir = nil
    return unless motion?

    dir ||= File.expand_path('../../motion', caller.first.split(':', 2).first)
    $LOAD_PATH.delete dir
    $LOAD_PATH.unshift dir
  end

  def motion?
    defined?(Motion::Project::Config)
  end

  def ext_file
    File.expand_path('../../motion/ext.rb', __FILE__)
  end

  def builtin_features
    %w(bigdecimal rational date thread)
  end
end
