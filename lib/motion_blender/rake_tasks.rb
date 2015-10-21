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
      files = config.incepted_files + Motion::Project::App.config.files
      files.flatten.each do |file|
        analyzer.analyze file
      end
      apply analyzer
    end

    def apply analyzer
      Motion::Project::App.setup do |app|
        new_files = analyzer.files - app.files
        app.exclude_from_detect_dependencies += new_files
        app.files = new_files + app.files
        app.files -= app.spec_files
        app.files_dependencies analyzer.dependencies
      end
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
