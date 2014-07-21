module Emarsys
  module Broadcast
    class TransferProtocol
      include Validation

      def initialize(config, key)
        validate_config(config, key)
        @config = config
      end

      protected

      def validate_config(config, key)
        fail ConfigurationError, 'configuration is nil, did you forget to configure the gem?' unless config
        %w(host user password).each do |arg|
          fail ConfigurationError, "#{key}_#{arg} must be configured" unless string_present? config.send("#{key}_#{arg}")
        end
        fail ConfigurationError, "#{key}_port must be integer between 1 and 65_535" unless within_range?(config.send("#{key}_port"), 1..65_535)
      end
    end
  end
end
