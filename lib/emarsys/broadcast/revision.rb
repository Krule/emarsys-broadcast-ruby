module Emarsys
  module Broadcast
    class Revision
      attr_accessor :id, :created

      def initialize(id, created)
        @id = id
        @created = created.to_datetime
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
