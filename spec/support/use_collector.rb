Module.new do
  def use_collector
    collector_class = MotionBlender::Collector

    let(:source) { double(file: src_file) }

    let(:collector) { collector_class.new(source, require: described_class) }

    let(:collector_requires) { collector_class.collect_requires(collector) }
  end

  RSpec.configure do |config|
    config.extend self
  end
end
