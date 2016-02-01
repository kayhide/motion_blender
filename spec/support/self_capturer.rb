module SelfCapturer
  def self.clear
    @captured_object = nil
  end

  def self.get
    @captured_object
  end

  def capture_self
    obj = self
    SelfCapturer.instance_eval { @captured_object = obj }
  end
end
