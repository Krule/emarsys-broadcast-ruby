module Emarsys
  module Broadcast
    class TransactionalMailing < BaseMailing
      attr_accessor :recipient_fields,
                    :recipients,
                    :revision

      validates :recipient_fields, presence: true, collection_like: true
      validates :body_text, presence: true
    end
  end
end
