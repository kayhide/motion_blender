require 'motion_blender/version'
require 'motion_blender/analyzer'
require 'motion_blender/rake_tasks'

module MotionBlender
  module_function

  def analyze
    Motion::Project::App.setup do |app|
      analyzer = Analyzer.new
      analyzer.exclude_files = Dir[File.expand_path('../**/*.rb', __FILE__)]
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

  def add file
    if defined?(Motion::Project::Config)
      Motion::Project::App.setup do |app|
        app.files.unshift file
      end
    end
  end

  def ext_file
    File.expand_path('../../motion/ext.rb', __FILE__)
  end
end
