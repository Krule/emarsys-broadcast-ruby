require 'nokogiri'
module Emarsys
  module Broadcast
    class XmlBuilder
      include Validation

      def import_xml(remote_path)
        xml = Nokogiri::XML::Builder.new do |xml|
          xml.importRequest {
            xml.filePath remote_path
            xml.properties {
              xml.property(key: 'Delimiter') { xml.text ',' }
              xml.property(key: 'Encoding') { xml.text 'UTF-8' }
            }
          }
        end
        xml.to_xml
      end

      private

      def validate_options(options)
        fail ArgumentError, 'options can not be nil' unless options
        fail ArgumentError, 'name is required' unless string_present? options[:name]
      end

    end
  end
end