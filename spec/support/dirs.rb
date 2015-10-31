Module.new do
  def fixtures_dir
    Bundler.root.join('spec/fixtures')
  end

  def tmp_dir
    Bundler.root.join('tmp')
  end

  RSpec.configure do |config|
    config.include self
  end
end

Module.new do
  def use_lib_dir
    let(:lib_dir) { fixtures_dir.join('lib') }

    before do
      $:.unshift lib_dir.to_s
    end

    after do
      $:.delete lib_dir.to_s
    end
  end

  def use_cache_dir
    let(:cache_dir) { tmp_dir.join('cache', SecureRandom.uuid) }

    before do
      MotionBlender.config.cache_dir = cache_dir
      cache_dir.mkpath
    end

    after do
      cache_dir.rmtree
    end
  end

  RSpec.configure do |config|
    config.extend self
  end
end
