require 'rake'
require 'motion_blender/config'
require 'motion_blender/analyzer'

module MotionBlender
  class RakeTasks
    def config
      MotionBlender.config
    end

    def analyze &proc
      Motion::Project::App.setup do |app|
        files = config.incepted_files + app.files
        analyzer = analyze_files files, &proc

        if analyzer.files.any?
          new_files = analyzer.files - app.files
          app.exclude_from_detect_dependencies += new_files
          app.files = new_files + app.files
          app.files_dependencies analyzer.dependencies
        end
      end
    end

    def analyze_files files, &proc
      analyzer = Analyzer.new
      analyzer.exclude_files += [*builtin_features, *config.excepted_files]

      files.flatten.each do |file|
        analyzer.analyze file, &proc
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
    tasks = MotionBlender::RakeTasks.new
    tasks.analyze do |file|
      Motion::Project::App.info('Analyze', file)
    end
  end
end

%w(build:simulator build:device).each do |t|
  task t => 'motion_blender:analyze'
end
