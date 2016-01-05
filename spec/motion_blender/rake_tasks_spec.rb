require 'spec_helper'
require 'motion_blender/rake_tasks'

module MotionBlender
  describe RakeTasks do
    let(:config) { MotionBlender.config }

    let(:analyzer) {
      Analyzer.new.tap do |analyzer|
        allow(Analyzer).to receive(:new) { analyzer }
      end
    }

    let(:app) {
      Struct.new(:name, :files, :spec_files, :exclude_from_detect_dependencies)
        .new('MotionBlender Test', [], [], []).tap do |app|
        allow(app).to receive(:files_dependencies)
      end
    }

    before do
      stub_const('Motion::Project::App', Module.new)
      allow(Motion::Project::App).to receive(:setup).and_yield(app)
      allow(Motion::Project::App).to receive(:config) { app }
      allow(Motion::Project::App).to receive(:info)
      allow(subject).to receive(:analyze) { analyzer }
    end

    describe '#analyze' do
      before do
        allow(subject).to receive(:analyze).and_call_original
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

    describe '#graph' do
      let(:dependencies) { { 'foo' => ['bar'] } }

      let(:options) { { a: 1, b: 2 } }

      before do
        allow(analyzer).to receive(:dependencies) { dependencies }
        allow_any_instance_of(GraphMaker).to receive(:build)
      end

      it 'calls analyze' do
        expect(subject).to receive(:analyze)
        subject.graph
      end

      it 'creates GraphMaker with dependencies and options' do
        expect(GraphMaker)
          .to receive(:new).with(dependencies, options).and_call_original
        subject.graph options
      end

      it 'sets GraphMaker#title' do
        graph_maker = GraphMaker.new dependencies
        allow(GraphMaker).to receive(:new) { graph_maker }
        expect(graph_maker).to receive(:title=).with('MotionBlender Test')
        subject.graph
      end

      it 'calls GraphMaker#build' do
        expect_any_instance_of(GraphMaker).to receive(:build)
        subject.graph
      end
    end
  end

  describe 'apply task' do
    subject { Rake::Task['motion_blender:apply'] }

    it 'calls RakeTasks#apply' do
      expect_any_instance_of(RakeTasks).to receive(:apply)
      subject.execute
    end

    it 'calls Motion::Project::App.info on parse' do
      allow_any_instance_of(RakeTasks).to receive(:apply)
      parser = double(file: 'foo')
      allow(MotionBlender).to receive(:on_parse) { |&p| p.call parser }
      stub_const('Motion::Project::App', Module.new)
      expect(Motion::Project::App).to receive(:info).with('Analyze', 'foo')
      subject.execute
    end
  end

  describe 'dump task' do
    subject { Rake::Task['motion_blender:dump'] }

    it 'puts dumped yaml' do
      expect_any_instance_of(RakeTasks).to receive(:dump) { 'dumped yaml' }
      expect {
        subject.execute
      }.to output(/dumped yaml/).to_stdout
    end
  end

  describe 'graph task' do
    subject { Rake::Task['motion_blender:graph'] }

    it 'calls RakeTasks#graph' do
      expect_any_instance_of(RakeTasks).to receive(:graph)
      subject.execute
    end

    it 'takes options from ENV' do
      options = {
        layout: 'dot',
        filter: 'pattern',
        output: 'garph.png'
      }
      stub_const('ENV', options.merge(dummy: 1).stringify_keys)
      expect_any_instance_of(RakeTasks).to receive(:graph).with(options)
      subject.execute
    end
  end
end
