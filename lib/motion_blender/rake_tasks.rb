require 'rake'
require 'yaml'
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
      analyzer
    end

    def apply
      analyzer = analyze
      Motion::Project::App.setup do |app|
        new_files = analyzer.files - app.files
        app.exclude_from_detect_dependencies += new_files
        app.files = new_files + app.files
        app.files -= app.spec_files
        app.files_dependencies analyzer.dependencies
      end
    end

    def dump
      analyzer = analyze
      YAML.dump %w(files dependencies).map { |k| [k, analyzer.send(k)] }.to_h
    end
  end
end

namespace :motion_blender do
  task :apply do
    MotionBlender.on_parse do |parser|
      Motion::Project::App.info('Analyze', parser.file)
    end
    MotionBlender::RakeTasks.new.apply
  end

  desc 'Dump analyzed files and dependencies'
  task :dump do
    puts MotionBlender::RakeTasks.new.dump
  end
end

%w(build:simulator build:device).each do |t|
  task t => 'motion_blender:apply'
end
