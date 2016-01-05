Module.new do
  def use_lib_dir
    let(:fixtures_dir) { Bundler.root.join('spec/fixtures') }

    let(:lib_dir) { fixtures_dir.join('lib') }

    before do
      $:.unshift lib_dir.to_s
    end

    after do
      $:.delete lib_dir.to_s
    end
  end

  RSpec.configure do |config|
    config.extend self
  end
end
