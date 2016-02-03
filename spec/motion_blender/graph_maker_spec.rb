require 'spec_helper'

describe MotionBlender::GraphMaker do
  use_lib_dir

  let(:dependencies) {
    foo = fixtures_dir.join('lib/foo.rb').to_s
    bar = fixtures_dir.join('lib/bar.rb').to_s
    { foo => [bar] }
  }

  let(:options) { {} }

  subject { MotionBlender::GraphMaker.new(dependencies, options) }

  describe '.new' do
    it 'creates with default options' do
      graph_maker = described_class.new dependencies
      expect(graph_maker.title).to eq nil
      expect(graph_maker.filter).to eq nil
      expect(graph_maker.layout).to eq :sfdp
      expect(graph_maker.output).to eq 'graph.pdf'
    end

    it 'sets options' do
      options = {
        title: 'Graph Title',
        filter: 'filter pattern',
        layout: :dot,
        output: 'graph.png'
      }
      graph_maker = described_class.new dependencies, options
      expect(graph_maker.title).to eq 'Graph Title'
      expect(graph_maker.filter).to eq 'filter pattern'
      expect(graph_maker.layout).to eq :dot
      expect(graph_maker.output).to eq 'graph.png'
    end
  end

  describe '#build' do
    let(:output) { tmp_dir.join('test/graph.pdf').to_s }

    before do
      FileUtils.rm output if File.exist? output
      FileUtils.mkpath File.dirname(output)
    end

    it 'creates output file' do
      options[:output] = output
      expect {
        subject.build
      }.to change { File.exist? output }.to(true)
    end
  end
end
