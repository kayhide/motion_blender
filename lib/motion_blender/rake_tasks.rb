require 'rake'
require 'motion_blender/config'
require 'motion_blender/analyzer'

module MotionBlender
  class RakeTasks
    def config
      MotionBlender.config
    end

    def analyze
      Motion::Project::App.setup do |app|
        files = config.incepted_files + app.files
        analyzer = analyze_files files

        if analyzer.files.any?
          new_files = analyzer.files - app.files
          app.exclude_from_detect_dependencies += new_files
          app.files = new_files + app.files
          app.files_dependencies analyzer.dependencies
        end
      end
    end

    def analyze_files files
      analyzer = Analyzer.new
      analyzer.exclude_files += [*builtin_features, *config.excepted_files]

      files.flatten.each do |file|
        analyzer.analyze file
      end
      analyzer
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
