require 'spec_helper'
require 'motion_blender/rake_tasks'

describe MotionBlender::RakeTasks do
  let(:config) {
    MotionBlender::Config.new.tap do |config|
      allow(subject).to receive(:config) { config }
    end
  }

  let(:analyzer) {
    MotionBlender::Analyzer.new.tap do |analyzer|
      allow(MotionBlender::Analyzer).to receive(:new) { analyzer }
    end
  }

  let(:app) {
    Struct.new(:files, :exclude_from_detect_dependencies)
      .new([], []).tap do |app|
      allow(app).to receive(:files_dependencies)
    end
  }

  before do
    config
    analyzer
  end

  describe '#analyze' do
    before do
      stub_const('Motion::Project::App', Module.new)
      allow(Motion::Project::App).to receive(:setup).and_yield(app)
    end

    it 'adds excepted files into Analyzer#exclude_files' do
      config.excepted_files << 'fizz' << 'bazz'

      subject.analyze
      expect(analyzer.exclude_files).to include 'fizz'
      expect(analyzer.exclude_files).to include 'bazz'
    end

    it 'calls Motion::Project::App.setup' do
      expect(Motion::Project::App).to receive(:setup).and_yield(app)
      subject.analyze
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

    it 'calls apply with analyzer and app' do
      allow(analyzer).to receive(:files) { %w(foo bar) }
      expect(subject).to receive(:apply).with(analyzer, app)
      subject.analyze
    end

    it 'skips apply when analyzer files is empty' do
      allow(analyzer).to receive(:files) { [] }
      expect(subject).not_to receive(:apply)
      subject.analyze
    end
  end

  describe '#apply' do
    it 'updates app with analyzer files and dependencies' do
      app.files << 'foo'
      allow(analyzer).to receive(:files) { %w(foo bar) }
      allow(analyzer).to receive(:dependencies) { { 'foo' => %w(bar) } }
      expect(app).to receive(:files_dependencies) { { 'foo' => %w(bar) } }
      subject.apply analyzer, app

      expect(app.files).to eq %w(bar foo)
      expect(app.exclude_from_detect_dependencies).to eq %w(bar)
    end
  end
end

describe 'analyze task' do
  let(:task) { Rake::Task['motion_blender:analyze'] }

  before do
    allow_any_instance_of(MotionBlender::RakeTasks).to receive(:analyze)
  end

  it 'exists' do
    expect(task).to be_a Rake::Task
  end

  it 'calls MotionBlender::RakeTasks#analyze' do
    expect_any_instance_of(MotionBlender::RakeTasks).to receive(:analyze)
    task.execute
  end

  it 'calls Motion::Project::App.info on parse' do
    parser = double(file: 'foo')
    allow(MotionBlender).to receive(:on_parse) { |&p| p.call parser }
    stub_const('Motion::Project::App', Module.new)
    expect(Motion::Project::App).to receive(:info).with('Analyze', 'foo')
    task.execute
  end
end
