module Emarsys
  module Broadcast
    class TransactionalMailing < BaseMailing
      attr_accessor :recipient_fields

      validates :recipient_fields, presence: true, collection_like: true
    end
  end
end
