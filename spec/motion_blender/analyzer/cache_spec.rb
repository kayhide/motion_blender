require 'spec_helper'
require 'motion_blender/analyzer/cache'

describe MotionBlender::Analyzer::Cache do
  use_cache_dir

  let(:app_dir) { tmp_dir.join('app').tap(&:mkpath) }

  let(:file) {
    t = 20.minutes.ago
    app_dir.join('foo.rb').tap do |f|
      FileUtils.touch f
      f.utime(t, t)
    end
  }

  let(:cache_file) {
    t = 5.minutes.ago
    cache_dir.join('foo.rb.yml').tap do |f|
      FileUtils.touch f
      f.utime(t, t)
    end
  }

  after do
    app_dir.rmtree
  end

  describe '#fetch' do
    it 'calls #read' do
      expect(subject).to receive(:read).with(cache_file)
      Dir.chdir file.dirname do
        subject.fetch(file.basename) do
        end
      end
    end

    it 'yields and calls #write if valid cache is not existant' do
      allow(subject).to receive(:valid_cache?) { false }
      expect(subject).to receive(:write).with(cache_file, 'content')
      Dir.chdir file.dirname do
        subject.fetch(file.basename) do
          'content'
        end
      end
    end

    it 'calls #write if failed in #read' do
      cache_file.write(': invalid_yaml')
      expect(subject).to receive(:write).with(cache_file, 'content')
      Dir.chdir file.dirname do
        subject.fetch(file.basename) do
          'content'
        end
      end
    end
  end

  describe '#read' do
    it 'reads cache' do
      cache_file.write <<-EOS.strip_heredoc
        ---
        - foo
        - bar
      EOS
      expect(subject.read(cache_file)).to eq %w(foo bar)
    end
  end

  describe '#write' do
    it 'writes content yaml' do
      subject.write cache_file, %w(foo bar)
      expect(YAML.load_file(cache_file)).to eq %w(foo bar)
    end

    it 'returns content' do
      expect(subject.write(cache_file, %w(foo bar))).to eq %w(foo bar)
    end
  end

  describe 'valid_cache?' do
    it 'returns true if cache is newer' do
      expect(subject.valid_cache?(file, cache_file)).to eq true
    end

    it 'returns false if cache is older' do
      FileUtils.touch file
      expect(subject.valid_cache?(file, cache_file)).to eq false
    end

    it 'returns false if not exist' do
      cache_file.delete
      expect(subject.valid_cache?(file, cache_file)).to eq false
    end
  end

  describe '#cache_file_for' do
    it 'returns cached file' do
      Dir.chdir app_dir do
        expect(subject.cache_file_for(Pathname.new('foo.rb')))
          .to eq cache_file
      end
    end

    it 'works with absolute path' do
      Dir.chdir app_dir do
        expect(subject.cache_file_for(Pathname.new('/foo.rb')))
          .to eq cache_file
      end
    end
  end
end
