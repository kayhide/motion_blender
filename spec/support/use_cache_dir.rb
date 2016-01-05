Module.new do
  def use_cache_dir
    use_tmp_dir

    let(:cache_dir) { tmp_dir.join('cache', SecureRandom.uuid) }

    before do
      MotionBlender.config.cache_dir = cache_dir
      cache_dir.mkpath
    end
  end

  RSpec.configure do |config|
    config.extend self
  end
end
