require 'uri'
module Emarsys
  module Broadcast
    class BaseMailing
      include ActiveModel::Validations
      attr_accessor :language,
                    :sender,
                    :sender_domain,
                    :body_html,
                    :body_text,
                    :name,
                    :sender_id,
                    :subject,
                    :status

      validates :name, :subject, :body_html, :sender, :sender_domain,
                presence: true

      validates :name, format: {
        with: /\A[a-z]\w*\z/i,
        message: 'must start with a letter and contain only letters, numbers and underscores' }

      validates :subject, length: { maximum: 255 }

      validates :sender, format: { with: Emarsys::Broadcast::Email::REGEX, message: 'is not a valid email' }

      validates :sender_domain, format: { with: URI::REL_URI, message: 'is not valid' }

      def initialize(attributes = {})
        attributes.each do |name, value|
          send("#{name}=", value)
        end
      end
    end
  end
end
