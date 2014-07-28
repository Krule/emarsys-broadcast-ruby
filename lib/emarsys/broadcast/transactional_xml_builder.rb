module Emarsys
  module Broadcast
    class TransactionalXmlBuilder < BaseXmlBuilder
      def build_xml(transactional)
        Nokogiri::XML::Builder.new do |xml|
          xml.mailing do
            xml.name transactional.name
            xml.properties { shared_properties(xml, transactional) }
            xml.recipientFields {
              transactional.recipient_fields.each do |field|
                xml.name field
              end
            }
            shared_nodes(xml, transactional)
          end
        end
      end
    end
  end
end
