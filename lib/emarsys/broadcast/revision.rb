module Emarsys
  module Broadcast
    class Revision
      attr_accessor :id

      def initialize(id)
        @id = id
      end

      def to_i
        id.to_i
      end

      def to_s
        id
      end
    end
  end
end
