require 'spec_helper'
require 'motion_blender/rake_tasks'

describe MotionBlender::RakeTasks do
  let(:config) { MotionBlender.config }

  let(:analyzer) {
    MotionBlender::Analyzer.new.tap do |analyzer|
      allow(MotionBlender::Analyzer).to receive(:new) { analyzer }
    end
  }

  let(:app) {
    Struct.new(:files, :spec_files, :exclude_from_detect_dependencies)
      .new([], [], []).tap do |app|
      allow(app).to receive(:files_dependencies)
    end
  }

  before do
    stub_const('Motion::Project::App', Module.new)
    allow(Motion::Project::App).to receive(:setup).and_yield(app)
    allow(Motion::Project::App).to receive(:config) { app }
  end

  describe '#analyze' do
    before do
      allow(analyzer).to receive(:analyze)
    end

    it 'calls analyze with incepted_files and app.files in order' do
      config.incepted_files << 'foo' << 'bar'
      app.files << 'hoge' << 'piyo'
      expect(analyzer).to receive(:analyze).with('foo').ordered
      expect(analyzer).to receive(:analyze).with('bar').ordered
      expect(analyzer).to receive(:analyze).with('hoge').ordered
      expect(analyzer).to receive(:analyze).with('piyo').ordered
      subject.analyze
    end
  end

  describe '#apply' do
    before do
      allow(subject).to receive(:analyze) { analyzer }
    end

    it 'calls analyze' do
      expect(subject).to receive(:analyze)
      subject.analyze
    end

    it 'calls Motion::Project::App.setup' do
      expect(Motion::Project::App).to receive(:setup).and_yield(app)
      subject.apply
    end

    it 'updates app with analyzer files and dependencies' do
      app.files << 'foo'
      allow(analyzer).to receive(:files) { %w(foo bar) }
      allow(analyzer).to receive(:dependencies) { { 'foo' => %w(bar) } }
      expect(app).to receive(:files_dependencies) { { 'foo' => %w(bar) } }
      subject.apply

      expect(app.files).to eq %w(bar foo)
      expect(app.exclude_from_detect_dependencies).to eq %w(bar)
    end
  end

  describe '#dump' do
    before do
      allow(subject).to receive(:analyze) { analyzer }
    end

    it 'calls analyze' do
      expect(subject).to receive(:analyze)
      subject.dump
    end

    it 'puts analyzer contents as yaml' do
      allow(analyzer).to receive(:files) { %w(foo bar) }
      allow(analyzer).to receive(:dependencies) { { 'foo' => %w(bar) } }
      expect(subject.dump).to eq <<-EOS.strip_heredoc
        ---
        files:
        - foo
        - bar
        dependencies:
          foo:
          - bar
      EOS
    end
  end
end

describe 'apply task' do
  let(:task) { Rake::Task['motion_blender:apply'] }

  it 'calls MotionBlender::RakeTasks#apply' do
    expect_any_instance_of(MotionBlender::RakeTasks).to receive(:apply)
    task.execute
  end

  it 'calls Motion::Project::App.info on parse' do
    allow_any_instance_of(MotionBlender::RakeTasks).to receive(:apply)
    parser = double(file: 'foo')
    allow(MotionBlender).to receive(:on_parse) { |&p| p.call parser }
    stub_const('Motion::Project::App', Module.new)
    expect(Motion::Project::App).to receive(:info).with('Analyze', 'foo')
    task.execute
  end
end

describe 'dump task' do
  let(:task) { Rake::Task['motion_blender:dump'] }

  it 'puts dumped yaml' do
    expect_any_instance_of(MotionBlender::RakeTasks)
      .to receive(:dump) { 'dumped yaml' }
    expect {
      task.execute
    }.to output(/dumped yaml/).to_stdout
  end
end
