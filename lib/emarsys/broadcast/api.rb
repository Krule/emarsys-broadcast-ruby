module Emarsys
  module Broadcast
    class API
      def initialize
        @config = Emarsys::Broadcast.configuration
        @logger = Emarsys::Broadcast.logger
        @sftp = SFTP.new @config
        @http = HTTP.new @config
        @xml_builder = XmlBuilder.new
      end

      def send_batch(batch)
        batch = supplement_batch_from_config batch
        create_batch batch
        upload_recipients batch.recipients_path
        trigger_import batch
      end

      def send_transactional(mailing)
        mailing = supplement_from_config(mailing)
        create_transactional(mailing)
        trigger_send(publish_transactional(mailing), mailing.recipients)
      end

      def create_recipient_field(name, type = 'text')
        recipient_field = RecipientField.new(name, type)
        @http.post('fields', recipient_field.to_xml)
      end

      def create_batch(batch)
        xml = BatchXmlBuilder.new.build(batch)
        @http.post("batches/#{batch.name}", xml)
      end

      def create_transactional(mailing)
        xml = TransactionalXmlBuilder.new.build(batch)
        @http.post("transactional_mailings/#{mailing.name}", xml)
      end

      def upload_recipients(recipients_path)
        @sftp.upload_file(recipients_path, File.basename(recipients_path))
      end

      def trigger_import(batch)
        import_xml = XmlBuilder.new.import_xml(File.basename(batch.recipients_path))
        @http.post("batches/#{batch.name}/import", import_xml)
      end

      def publish_transactional(mailing)
        response = @http.post("transactional_mailings/#{mailing.name}/revisions", '<nothing/>')
        Nokogiri::XML(response).xpath('//revision').map{ |n| Revision.new(n.attr('id')) }
      end

      # recipients = CSV.string
      def trigger_send(revision, recipients)
        unless revision.present?
          return @logger.error(self) { 'no revision published yet' }
        end
        @http.post("transactional_mailings/#{mailing.name}/revisions/#{mailing.revision/recipients}", recipients_string)
      end

      def retrieve_batch_mailings
        response = @http.get('batches')
        Nokogiri::XML(response).xpath('//batch').map do |node|
          BatchMailing.new(
            name: node.attr('id'),
            status: node.xpath('status').text,
            send_time: DateTime.parse(node.xpath('sendDate').text),
            subject: node.xpath('subject').text
          )
        end
      end

      def retrieve_sender_domains
        response = @http.get('domains')
        Nokogiri::XML(response).xpath('//domain').map do |node|
          SenderDomain.new(node.text)
        end
      end

      def retrieve_sender_domain(domain)
        retrieve_sender_domains.find { |d| d.host == domain }
      end

      def retrieve_fields
        response = @http.get('fields')
        Nokogiri::XML(response).xpath('//field').map do |node|
          RecipientField.new(node.attr('name'), node.attr('type'))
        end
      end

      def retrieve_transactional_mailings
        response = @http.get('transactional_mailings')
        Nokogiri::XML(response).xpath('//mailings').map do |node|
          TransactionalMailing.new(id: node.attr('name'))
        end
      end

      def retrieve_senders
        response = @http.get('senders')
        Nokogiri::XML(response).xpath('//sender').map do |node|
          Sender.new(node.attr('id'), node.xpath('name').text, node.xpath('address').text)
        end
      end

      def retrieve_sender_by_email(email)
        retrieve_senders.find { |s| s.address == email }
      end

      def retrieve_sender(id)
        retrieve_senders.find { |s| s.id == id }
      end

      def create_sender(sender)
        @http.put("senders/#{sender.id}", sender.to_xml)
      end

      def sender_exists?(email)
        retrieve_senders.any? { |s| s.address == email.to_s }
      end

      def supplement_batch_from_config(batch)
        batch.import_delay_hours ||= @config.import_delay_hours
        batch.recipients_path ||= @config.recipients_path
        batch.send_time ||= Time.now
        supplement_from_config(batch)
      end

      def supplement_from_config(mailing)
        mailing.sender ||= retrieve_sender_by_email(@config.default_sender)
        validate_sender(mailing.sender)
        mailing.sender_domain ||= SenderDomain.new(@config.sender_domain)
        validate_mailing(mailing)
        mailing
      end

      private

      def validate_mailing(mailing)
        fail ValidationError.new('Mailing is invalid', mailing.errors.full_messages) unless mailing.valid?
      end

      def validate_sender(sender)
        msg = "Email `#{sender}` is not registered with Emarsys as a sender, register it with `create_sender` api call"
        fail ValidationError.new(msg, [msg]) if sender && !sender_exists?(sender)
      end
    end
  end
end