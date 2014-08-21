module Emarsys
  module Broadcast
    class ApiError
      attr_accessor :id, :message

      def initialize(id, message)
        @id = id
        @message = message
        self
      end

      def to_s
        "Error(#{id}): #{message}"
      end
    end
  end
end
