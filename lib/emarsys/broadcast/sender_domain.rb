module Emarsys
  module Broadcast
    class SenderDomain
      attr_reader :host

      def initialize(host)
        @host = host
      end

      def to_s
        host
      end
    end
  end
end
