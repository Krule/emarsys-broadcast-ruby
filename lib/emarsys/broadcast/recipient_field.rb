module Emarsys
  module Broadcast
    class RecipientField
      attr_reader :name, :type

      def initialize(name, type)
        @name, @type = name, type
      end

      def to_s
        name
      end
    end
  end
end