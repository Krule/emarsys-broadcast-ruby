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

      def batch_mailing_status(id)
        response = @http.get("batches/#{id}/status")
        handle_error_reponse(key: 'status', response: response) do |node|
          Status.new(node.text)
        end
      end

      def transactional_mailing_status(id)
        retrieve_transactional_mailing_by_name(id) unless id.blank?
      end

      def batch_mailing_import_status(id)
        response = @http.get("batches/#{id}/import/status")
        handle_error_reponse(key: 'import', response: response) do |node|
          ImportStatus.new(node.css('status').text) do |is|
            is.created = DateTime.parse(node.css('created').text)
            is.updated = DateTime.parse(node.css('updated').text)
            if node.css('error').present?
              is.error = node.css('error').text
            else
              is.imported_count = node.css('imported_count').text
              is.invalid_count = node.css('invalid_count').text
              is.column_count = node.css('column_count').text
              is.file_size = node.css('file_size').text
            end
          end
        end
      end

      def send_batch(batch)
        create_batch(batch)
        upload_recipients batch.recipients_path
        trigger_import batch
      end

      def send_transactional(mailing)
        create_transactional(mailing)
        trigger_send(publish_transactional(mailing), mailing.recipients)
      end

      def create_recipient_field(name, type = 'text')
        recipient_field = RecipientField.new(name, type)
        @logger.info(self){ "Recipient field #{name} saved" }
        @http.post('fields', recipient_field.to_xml)
      end

      def create_batch(batch)
        xml = BatchXmlBuilder.new.build(supplement_batch_from_config(batch))
        @logger.info(self){ "Batch mailing `#{batch}` saved" }
        response = @http.post("batches/#{batch}", xml)
        handle_error_reponse(response: response)
      end

      def create_transactional(mailing)
        xml = TransactionalXmlBuilder.new.build(supplement_from_config(mailing))
        @logger.info(self){ "Transactional mailing `#{mailing}` saved" }
        @http.post("transactional_mailings/#{mailing}", xml)
      end

      def upload_recipients(batch, local_path)
        @sftp.upload_file(batch, local_path)
      end

      def trigger_import(batch)
        import_xml = XmlBuilder.new.import_xml(batch.recipients_path)
        response = @http.post("batches/#{batch}/import", import_xml)
        @logger.info(self){ "Import for #{batch} triggered and responded with #{response}" }
      end

      def trigger_test(batch, recipients_xml)
        @logger.info(self){ "Import for #{batch} triggered" }
        @http.post("batches/#{batch}/test", recipients_xml)
      end

      def publish_transactional(mailing)
        revisions = retrieve_revisions(mailing)
        #
        # Delete first revision in case we are at the limit
        # Implement different strategies and extract strategy definition to config
        #
        destroy_revision(mailing, revisions.first) if revisions.size == 10
        response = @http.post("transactional_mailings/#{mailing}/revisions", '<nothing/>')
        @logger.info(self){ "Transactional mailing `#{mailing}` revision published" }
        Nokogiri::XML(response).xpath('//revision').map do |n|
          mailing.revision = Revision.new(n.attr('id'), n.attr('created'))
        end
      end

      def destroy_batch(batch)
        @logger.info(self){ "Batch mailing `#{batch}` destroyed" }
        @http.delete("batches/#{batch}")
      end

      def destroy_revision(mailing, revision)
        @logger.info(self){ "Transactional mailing `#{mailing}` revision ##{revision} destroyed" }
        @http.delete("transactional_mailings/#{mailing}/revisions/#{revision}")
      end

      def trigger_send(mailing, csv_string)
        return @logger.error(self) { 'no revision published yet' } unless mailing.revision.present?
        @logger.info(self){ "Transactional mailing #{mailing} revision #{mailing.revision} send triggered" }
        @http.post_csv("transactional_mailings/#{mailing}/revisions/#{mailing.revision}/recipients", csv_string)
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

      def retrieve_batch_by_name(name)
        response = @http.get("batches/#{name}")
        handle_error_reponse(key: 'batch', response: response) do |node|
          BatchMailing.new(
            name: node.attr('id').value,
            send_time: DateTime.parse(node.css('runDate').text),
            send_time: node.css('subject').text
          )
        end
      end

      def retrieve_revisions(mailing)
        response = @http.get("transactional_mailings/#{mailing}/revisions")
        Nokogiri::XML(response).xpath('//revision').map do |node|
          Revision.new(node.attr('id'), node.attr('created'))
        end
      end

      # :first, :last, numeric (1..10)
      def retrieve_revision(mailing, position)
        position = -1 if position == :last
        position = 0 if position == :first
        retrieve_revisions(mailing)[position]
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
        Nokogiri::XML(response).xpath('//mailing').map do |node|
          TransactionalMailing.new(name: node.attr('id'))
        end
      end

      def retrieve_transactional_mailing_by_name(name)
        response = @http.get("transactional_mailings/#{name}")
        handle_error_reponse(key: 'mailing', response: response) do |node|
          TransactionalMailing.new(name: node.first.attr('id'))
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
        response = @http.get("senders/#{id}")
        handle_error_reponse(key: 'sender', response: response) do |node|
          Sender.new(node.attr('id'), node.xpath('name').text, node.xpath('address').text)
        end
      end

      def create_sender(id, name, address)
        sender = Sender.new(id, name, address)
        response = @http.put("senders/#{sender.id}", sender.to_xml)
        handle_error_reponse(response: response)
      end

      def destroy_sender(id)
        @logger.info(self){ "Sender `#{id}` destroyed" }
        @http.delete("senders/#{id}")
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

      # Key must be present if block is given
      def handle_error_reponse(data = { key: nil, response: nil })
        xml = Nokogiri::XML(data[:response])
        if block_given?
          node = xml.css(data[:key])
          return yield(node) if node.present?
        else
          return '' if data[:response].empty?
        end
        node = xml.css('ERROR')
        fail ApiError.new(node.attr('id'), node.text)
      end

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
