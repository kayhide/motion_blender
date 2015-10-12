require 'motion_blender/version'
require 'motion_blender/analyzer'
require 'motion_blender/rake_tasks'

module MotionBlender
  module_function

  def analyze
    Motion::Project::App.setup do |app|
      analyzer = Analyzer.new
      analyzer.exclude_files += Dir[File.expand_path('../**/*.rb', __FILE__)]
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
    if defined?(Motion::Project::Config)
      unless file
        file = caller.first.split(':', 2).first
      end
      Motion::Project::App.setup do |app|
        app.files.unshift file
      end
    end
  end

  def use_motion_dir dir = nil
    unless dir
      file = caller.first.split(':', 2).first
      dir = File.expand_path('../../motion', file)
    end
    $LOAD_PATH.delete dir
    $LOAD_PATH.unshift dir
  end

  def ext_file
    File.expand_path('../../motion/ext.rb', __FILE__)
  end
end
