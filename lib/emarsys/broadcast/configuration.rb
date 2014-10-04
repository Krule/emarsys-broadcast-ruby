module Emarsys
  module Broadcast
    class ConfigurationError < StandardError; end

    class Configuration
      attr_accessor :api_base_path,
                    :api_host,
                    :api_password,
                    :api_port,
                    :api_timeout,
                    :api_user,
                    :import_delay_hours, # https://e3.emarsys.net/bmapi/v2/doc/Properties.html#ImportDelay
                    :recipients_path,
                    :default_sender,
                    :sender_domain, # http://api.broadcast2.emarsys.net/doc/v2/Domains.html#Domains
                    :sftp_host,
                    :sftp_password,
                    :sftp_port,
                    :sftp_user

      def initialize
        @sftp_host = 'e3.emarsys.net'
        @sftp_port = 22
        @api_host = 'api.broadcast1.emarsys.net'
        @api_base_path = '/v2'
        @api_port = 433
        @api_timeout = 10 # seconds
        @import_delay_hours = 1
      end
    end

    class << self
      attr_accessor :configuration, :logger
    end

    def self.configure
      self.configuration ||= Configuration.new
      self.logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
      yield configuration
      configuration
    end
  end
end
