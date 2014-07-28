# encoding: UTF-8
require 'bundler/setup'
require 'emarsys/broadcast'
require 'timecop'
require 'webmock/rspec'
require 'digest/sha1'


def restore_default_config
  Emarsys::Broadcast.configuration = nil
  Emarsys::Broadcast.configure {}
end

def create_valid_config
  Emarsys::Broadcast::configure do |c|
    c.sftp_host = 'a'
    c.sftp_user = 'a'
    c.sftp_password = 'a'

    c.api_user = 'a'
    c.api_password = 'a'

    c.default_sender = spec_sender
    c.recipients_path = '/some/path.csv'
  end
end

def create_minimal_batch
  batch = Emarsys::Broadcast::BatchMailing.new
  batch.language = 'en'
  batch.name = 'batch_name'
  batch.subject = 'subject'
  batch.body_html = 'body'
  batch.send_time = spec_time
  batch.sender = api.retrieve_sender_by_email('sender1@example.com')
  batch.sender_domain = 'e3.emarsys.net'
  batch
end

def create_minimal_html_batch
  batch = Emarsys::Broadcast::BatchMailing.new
  batch.language = 'en'
  batch.name="batch_name"
  batch.subject = 'subject'
  batch.body_html = '<h1>hello</h1>'
  batch.send_time = spec_time
  batch.sender = api.retrieve_sender_by_email('sender1@example.com')
  batch.sender_domain = 'e3.emarsys.net'
  batch
end

def spec_time
  Time.new(2013, 12, 31, 0, 0, 0, "+00:00")
end

def spec_sender
  'abc@example.com'
end

def mock_password
  Digest::SHA1.hexdigest('a')
end

def stub_senders_ok_two_senders(senders = [])
  fixture_path = File.dirname(__FILE__) + '/fixtures/responses/senders_200_two_senders.http'
  stub_request(:get, "https://a:#{mock_password}@api.broadcast1.emarsys.net/v2/senders")
    .with(:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/xml', 'User-Agent'=>'Ruby'})
    .to_return(File.new fixture_path)
end

def stub_post_ok
  fixture_path = File.dirname(__FILE__) + '/fixtures/responses/ok.http'
  stub_request(:post, %r{https://a:#{mock_password}@api.broadcast1.emarsys.net/v2/.*}).to_return(http_ok)
end

def http_ok
  fixture_path = File.dirname(__FILE__) + '/fixtures/responses/ok.http'
  File.new fixture_path
end

