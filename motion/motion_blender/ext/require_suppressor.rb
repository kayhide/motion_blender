Module.new do
  def require _
  end

  def require_relative _
  end

  def motion_require _
  end

  Object.send :include, self
end
