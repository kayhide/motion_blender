require 'rake'
require 'motion_blender'

namespace :motion_blender do
  task :analyze do
    MotionBlender.analyze
  end
end

%w(build:simulator build:device).each do |t|
  task t => 'motion_blender:analyze'
end
