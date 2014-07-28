require 'spec_helper'

describe Emarsys::Broadcast::BatchXmlBuilder do
  before(:each) do
    create_valid_config
    stub_senders_ok_two_senders
  end
  let(:config) { create_valid_config }
  let(:api){ Emarsys::Broadcast::API.new }
  let(:batch_builder) { Emarsys::Broadcast::BatchXmlBuilder.new }
  let(:minimal_batch) { create_minimal_batch }
  let(:minimal_html_batch)  { create_minimal_html_batch }
  describe 'initialize' do
    it 'should create a new instance of BatchXmlBuilder' do
      expect(batch_builder).not_to be_nil
    end
  end

  describe '#build' do
    it 'should return a valid Emarsys Xml XML string' do
      actual_xml = batch_builder.build(minimal_batch).chomp
      fixture_path = File.dirname(__FILE__) + '/fixtures/xml/minimal_batch.xml'
      expected_xml = File.read(fixture_path)
      expect(actual_xml).to eq expected_xml
    end

    it 'should properly escape the body of the Emarsys Xml XML string' do
      actual_xml = batch_builder.build(minimal_html_batch).chomp
      fixture_path = File.dirname(__FILE__) + '/fixtures/xml/minimal_escaped_batch.xml'
      expected_xml = File.read(fixture_path)
      expect(actual_xml).to eq expected_xml
    end
  end
end
