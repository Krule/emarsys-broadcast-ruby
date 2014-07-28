module Emarsys
  module Broadcast
    class API
      def initialize
        @config = Emarsys::Broadcast.configuration
        @sftp = SFTP.new @config
        @http = HTTP.new @config
        @xml_builder = XmlBuilder.new
      end

      def send_batch(batch)
        batch = supplement_mailing_from_config(batch)
        validate_mailing(batch)
        validate_sender(batch.sender)
        create_batch(batch)
        upload_recipients(batch.recipients_path)
        trigger_import(batch)
      end

      def send_transaction(transaction)
        transaction = supplement_mailing_from_config()
      end

      def create_batch(batch)
        emarsys_sender = retrieve_sender(batch.sender)
        batch.sender_id = emarsys_sender.id
        batch_xml = BatchXmlBuilder.new.build(batch)
        @http.post("batches/#{batch.name}", batch_xml)
      end

      def upload_recipients(recipients_path)
        @sftp.upload_file(recipients_path, File.basename(recipients_path))
      end

      def trigger_import(batch)
        import_xml = XmlBuilder.new.import_xml(File.basename(batch.recipients_path))
        @http.post("batches/#{batch.name}/import", import_xml)
      end

      def retrieve_fields
        response = @http.get("fields")
        Nokogiri::XML(response).xpath('//field').map do |node|
          RecipientField.new(node.attr('name'), node.attr('type'))
        end
      end

      def retrieve_transactional_mailings
        response = @http.get("transactional_mailings")
        # TODO: Parse into object
      end

      def retrieve_senders
        response = @http.get("senders")
        Nokogiri::XML(response).xpath('//sender').map do |node|
          Sender.new(node.attr('id'), node.xpath('name').text, node.xpath('address').text)
        end
      end

      def retrieve_sender(email)
        retrieve_senders.find { |s| s.address == email }
      end

      def create_sender(sender)
        sender_xml = @xml_builder.sender_xml(sender)
        @http.put("senders/#{sender.id}", sender_xml)
      end

      def sender_exists?(email)
        retrieve_senders.any? { |s|s.address == email }
      end

      private

      def supplement_mailing_from_config(mailing)
        mailing.recipients_path ||= @config.recipients_path
        mailing.send_time ||= Time.now
        mailing.sender ||= @config.sender
        mailing.sender_domain ||= @config.sender_domain
        mailing.import_delay_hours ||= @config.import_delay_hours
        mailing
      end

      def validate_mailing(mailing)
        fail ValidationError.new('Mailing is invalid', mailing.errors.full_messages) unless mailing.valid?
      end

      def validate_sender(email)
        msg = "Email `#{email}` is not registered with Emarsys as a sender, register it with `create_sender` api call"
        fail ValidationError.new(msg, [msg]) unless sender_exists? email
      end
    end
  end
end