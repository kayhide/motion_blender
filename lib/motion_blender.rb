require 'motion_blender/version'
require 'motion_blender/rake_tasks'

module MotionBlender
  module_function

  def add file = nil
    return unless motion?

    file ||= caller.first.split(':', 2).first
    Motion::Project::App.setup do |app|
      app.files.unshift file
    end
  end

  def use_motion_dir dir = nil
    return unless motion?

    unless dir
      file = caller.first.split(':', 2).first
      Pathname.new(file).dirname.ascend do |path|
        if $LOAD_PATH.include?(path.to_s)
          dir = path.dirname.join('motion').to_s
          break
        end
      end
    end
    $LOAD_PATH.delete dir
    $LOAD_PATH.unshift dir
  end

  def motion?
    defined?(Motion) && defined?(Motion::Project)
  end

  def raketime?
    true
  end

  def runtime?
    false
  end

  def raketime &proc
    proc.call
  end

  def runtime &_
  end
end
