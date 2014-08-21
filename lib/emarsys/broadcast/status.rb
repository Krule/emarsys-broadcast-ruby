module Emarsys
  module Broadcast
    class Status
      attr_accessor :message

      def initialize(message)
        @message = message
        self
      end

      def to_s
        message
      end
    end
  end
end
