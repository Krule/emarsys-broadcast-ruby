module Emarsys
  module Broadcast
    class Sender
      attr_reader :id, :name, :address

      def initialize(id, name, address)
        @id, @name, @address = id, name, address
      end

      def to_s
        address
      end

      def to_xml
        Nokogiri::XML::Builder.new do |xml|
          xml.sender do
            xml.name(name)
            xml.address(address)
          end
        end.to_xml
      end
    end
  end
end