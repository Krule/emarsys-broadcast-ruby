require 'active_model'
require 'emarsys/validators/collection_like_validator'
require 'emarsys/broadcast/version'
require 'emarsys/broadcast/api_error'
require 'emarsys/broadcast/email'
require 'emarsys/broadcast/validation'
require 'emarsys/broadcast/configuration'
require 'emarsys/broadcast/transfer_protocol'
require 'emarsys/broadcast/sftp'
require 'emarsys/broadcast/http'
require 'emarsys/broadcast/validation_error'
require 'emarsys/broadcast/base_mailing'
require 'emarsys/broadcast/batch_mailing'
require 'emarsys/broadcast/transactional_mailing'
require 'emarsys/broadcast/batch' # deprecate in favor of batch_mailing
require 'emarsys/broadcast/recipient_field'
require 'emarsys/broadcast/revision'
require 'emarsys/broadcast/sender'
require 'emarsys/broadcast/sender_domain'
require 'emarsys/broadcast/status'
require 'emarsys/broadcast/import_status'
require 'emarsys/broadcast/base_xml_builder'
require 'emarsys/broadcast/batch_xml_builder'
require 'emarsys/broadcast/transactional_xml_builder'
require 'emarsys/broadcast/xml_builder'
require 'emarsys/broadcast/api'

module Emarsys
  module Broadcast
  end
end
