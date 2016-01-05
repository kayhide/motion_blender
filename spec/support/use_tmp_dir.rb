Module.new do
  def use_tmp_dir
    let(:tmp_dir) { Bundler.root.join('tmp/test') }

    before do
      tmp_dir.mkpath
    end

    after do
      tmp_dir.rmtree
    end
  end

  RSpec.configure do |config|
    config.extend self
  end
end
