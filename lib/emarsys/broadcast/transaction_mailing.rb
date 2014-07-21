module Emarsys
  module Broadcast
    class TransactionMailing < BaseMailing
      attr_accessor :email,
                    :export_id,
                    :registration_type

      def create
      end
    end
  end
end
