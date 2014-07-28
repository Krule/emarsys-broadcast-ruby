require 'nokogiri'
require 'action_view'
module Emarsys
  module Broadcast
    class BaseXmlBuilder
      include ActionView::Helpers::SanitizeHelper
      def build(arg)
        fail ArgumentError, 'argument is required' unless arg
        build_xml(arg).to_xml
      end

      def build_xml(_); end

      protected

      def shared_nodes(xml, mailing)
        xml.subject mailing.subject
        xml.html mailing.body_html
        xml.text_ mailing.body_text || strip_tags(mailing.body_html)
      end

      def shared_properties(xml, mailing)
        xml.property(key: :Sender) { xml.text mailing.sender.id }
        xml.property(key: :Language) { xml.text mailing.language }
        xml.property(key: :Encoding) { xml.text 'UTF-8' }
        xml.property(key: :Domain) { xml.text mailing.sender_domain }
      end

      def format_time(time)
        time.strftime('%Y-%m-%dT%H:%M:%S%z')
      end
    end
  end
end
