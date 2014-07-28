require 'spec_helper'

describe Emarsys::Broadcast::TransactionalXmlBuilder do
  before(:each) do
    create_valid_config
    stub_senders_ok_two_senders
  end
  let(:config) { create_valid_config }
  let(:api) { Emarsys::Broadcast::API.new }
  let(:transactional_builder) {  Emarsys::Broadcast::TransactionalXmlBuilder.new }
  let(:minimal_transaction) { create_minimal_transaction }
  let(:minimal_html_transaction)  { create_minimal_html_transaction }
  describe 'initialize' do
    it 'should create a new instance of BatchXmlBuilder' do
      expect(transactional_builder).not_to be_nil
    end
  end

  describe '#build' do
    it 'should return a valid Emarsys Xml XML string' do
      actual_xml = transactional_builder.build(minimal_transaction).chomp
      fixture_path = File.dirname(__FILE__) + '/fixtures/xml/minimal_transaction.xml'
      expected_xml = File.read(fixture_path)
      expect(actual_xml).to eq expected_xml
    end

    it 'should properly escape the body of the Emarsys Xml XML string' do
      actual_xml = transactional_builder.build(minimal_html_transaction).chomp
      fixture_path = File.dirname(__FILE__) + '/fixtures/xml/minimal_escaped_transaction.xml'
      expected_xml = File.read(fixture_path)
      expect(actual_xml).to eq expected_xml
    end
  end
end
