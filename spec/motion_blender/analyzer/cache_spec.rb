require 'spec_helper'
require 'motion_blender/analyzer/cache'

module MotionBlender
  describe Analyzer::Cache do
    use_cache_dir

    subject { described_class.new file.basename }

    let(:app_dir) { tmp_dir.join('app').tap(&:mkpath) }

    let!(:file) {
      t = 20.minutes.ago
      app_dir.join('foo.rb').tap do |f|
        FileUtils.touch f
        f.utime(t, t)
      end
    }

    let!(:cache_file) {
      t = 5.minutes.ago
      cache_dir.join('foo.rb.yml').tap do |f|
        FileUtils.touch f
        f.utime(t, t)
      end
    }

    before do
      @old_dir = Dir.pwd
      Dir.chdir app_dir
    end

    after do
      Dir.chdir @old_dir
      app_dir.rmtree
    end

    describe '#hit?' do
      it 'returns true if #fetch hits' do
        subject.fetch { 'content' }
        expect(subject).to be_hit
      end

      it 'returns false if #fetch does not hit' do
        cache_file.delete
        subject.fetch { 'content' }
        expect(subject).not_to be_hit
      end
    end

    describe '#fetch' do
      it 'calls #read' do
        expect(subject).to receive(:read)
        subject.fetch { 'content' }
      end

      it 'yields and calls #write if cache is not valid' do
        allow(subject).to receive(:valid?) { false }
        expect(subject).to receive(:write).with('content')
        subject.fetch { 'content' }
      end

      it 'calls #write if failed in #read' do
        cache_file.write(': invalid_yaml')
        expect(subject).to receive(:write).with('content')
        subject.fetch { 'content' }
      end
    end

    describe '#read' do
      it 'reads cache' do
        cache_file.write <<-EOS.strip_heredoc
          ---
          - foo
          - bar
        EOS
        expect(subject.read).to eq %w(foo bar)
      end
    end

    describe '#write' do
      it 'writes content yaml' do
        subject.write %w(foo bar)
        expect(YAML.load_file(cache_file)).to eq %w(foo bar)
      end

      it 'returns content' do
        expect(subject.write(%w(foo bar))).to eq %w(foo bar)
      end

      it 'deletes if content is nil' do
        expect(subject).to receive(:delete)
        subject.write(nil)
      end
    end

    describe '#valid?' do
      it 'returns true if cache is newer' do
        expect(subject).to be_valid
      end

      it 'returns false if cache is older' do
        FileUtils.touch file
        expect(subject).not_to be_valid
      end

      it 'returns false if not exist' do
        cache_file.delete
        expect(subject).not_to be_valid
      end
    end

    describe '#cache_file' do
      it 'returns cached file' do
        expect(subject.cache_file).to eq cache_file
      end

      describe 'with absolute path' do
        subject { described_class.new '/foo.rb' }

        it 'works ' do
          expect(subject.cache_file).to eq cache_file
        end
      end
    end
  end
end
