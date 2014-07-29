require 'nokogiri'
module Emarsys
  module Broadcast
    class RecipientField

      TYPES = %w(text numeric)

      attr_reader :name, :type

      def initialize(name, type)
        @name, @type = name, type
      end

      def to_s
        name
      end

      def to_xml
        Nokogiri::XML::Builder.new do |xml|
          xml.fields do
            xml.field(name: name, type: type)
          end
        end.to_xml
      end
    end
  end
end
