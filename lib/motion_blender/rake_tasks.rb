require 'rake'
require 'motion_blender/config'
require 'motion_blender/analyzer'

module MotionBlender
  class RakeTasks
    def config
      MotionBlender.config
    end

    def analyze
      analyzer = Analyzer.new
      analyzer.exclude_files += builtin_features + config.excepted_files
      Motion::Project::App.setup do |app|
        files = config.incepted_files + app.files
        files.flatten.each do |file|
          analyzer.analyze file
        end
        apply analyzer, app if analyzer.files.any?
      end
    end

    def apply analyzer, app
      new_files = analyzer.files - app.files
      app.exclude_from_detect_dependencies += new_files
      app.files = new_files + app.files
      app.files_dependencies analyzer.dependencies
    end

    def builtin_features
      %w(bigdecimal rational date thread)
    end
  end
end

namespace :motion_blender do
  task :analyze do
    MotionBlender.on_parse do |parser|
      Motion::Project::App.info('Analyze', parser.file)
    end
    MotionBlender::RakeTasks.new.analyze
  end
end

%w(build:simulator build:device).each do |t|
  task t => 'motion_blender:analyze'
end
