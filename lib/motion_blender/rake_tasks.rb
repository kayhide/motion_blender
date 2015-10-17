require 'rake'
require 'motion_blender/analyzer'

module MotionBlender
  class RakeTasks
    def analyze
      Motion::Project::App.setup do |app|
        analyzer = Analyzer.new
        analyzer.exclude_files += Dir[File.expand_path('../../**/*.rb', __FILE__)]
        analyzer.exclude_files += builtin_features

        files = app.files
        files.flatten.each do |file|
          analyzer.analyze file
        end

        if analyzer.files.any?
          new_files = analyzer.files - files
          app.exclude_from_detect_dependencies += [ext_file, *new_files]
          app.files = [ext_file, *new_files, *app.files]
          app.files_dependencies analyzer.dependencies
        end
      end
    end

    def ext_file
      File.expand_path('../../../motion/ext.rb', __FILE__)
    end

    def builtin_features
      %w(bigdecimal rational date thread)
    end
  end
end

namespace :motion_blender do
  task :analyze do
    tasks = MotionBlender::RakeTasks.new
    tasks.analyze
  end
end

%w(build:simulator build:device).each do |t|
  task t => 'motion_blender:analyze'
end
