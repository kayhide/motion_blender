require 'tsort'

module MotionBlender
  class DependencyGraph < Hash
    include TSort

    alias_method :tsort_each_node, :each_key

    def tsort_each_child node, &block
      (self[node] || []).each(&block)
    end
  end
end
