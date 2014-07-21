require 'spec_helper'

describe Emarsys::Broadcast::Batch do
  it 'should initialize a new instance of batch' do
    silence_warnings do
      expect(Emarsys::Broadcast::Batch.new).not_to be_nil
    end
  end
end
