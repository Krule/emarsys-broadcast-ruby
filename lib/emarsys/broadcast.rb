require 'active_model'
require 'emarsys/broadcast/version'
require 'emarsys/broadcast/email'
require 'emarsys/broadcast/validation'
require 'emarsys/broadcast/configuration'
require 'emarsys/broadcast/transfer_protocol'
require 'emarsys/broadcast/sftp'
require 'emarsys/broadcast/http'
require 'emarsys/broadcast/validation_error'
require 'emarsys/broadcast/base_mailing'
require 'emarsys/broadcast/batch_mailing'
require 'emarsys/broadcast/transaction_mailing'
require 'emarsys/broadcast/batch' # deprecate in favor of batch_mailing
require 'emarsys/broadcast/recipient_field'
require 'emarsys/broadcast/sender'
require 'emarsys/broadcast/base_xml_builder'
require 'emarsys/broadcast/batch_xml_builder'
require 'emarsys/broadcast/transaction_xml_builder'
require 'emarsys/broadcast/xml_builder'
require 'emarsys/broadcast/api'

module Emarsys
  module Broadcast
  end
end
