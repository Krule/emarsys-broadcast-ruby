module Emarsys
  module Broadcast
    class BatchXmlBuilder < BaseXmlBuilder
      def build_xml(batch)
        Nokogiri::XML::Builder.new do |xml|
          xml.batch do
            xml.name batch.name
            xml.runDate format_time(batch.send_time)
            xml.properties do
              shared_properties(xml, batch)
              xml.property(key: :ImportDelay) { xml.text batch.import_delay_hours }
            end
            shared_nodes(xml, batch)
          end
        end
      end
    end
  end
end
