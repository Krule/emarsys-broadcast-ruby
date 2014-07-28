module Emarsys
  module Broadcast
    class TransactionXmlBuilder < BaseXmlBuilder
      def build_xml(transaction)
        Nokogiri::XML::Builder.new do |xml|
          xml.mailing do
            xml.name transaction.name
            xml.properties { shared_properties(xml, transaction) }
            xml.recipientFields {

            }
            shared_nodes(xml, transaction)
          end
        end
      end
    end
  end
end
