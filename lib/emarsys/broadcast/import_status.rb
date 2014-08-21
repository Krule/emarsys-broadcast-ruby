module Emarsys
  module Broadcast
    class ImportStatus
      attr_accessor :column_count,
                    :created,
                    :error,
                    :file_size,
                    :imported_count,
                    :invalid_count,
                    :status,
                    :updated

      def initialize(status)
        @status = status
        yield self
        self
      end

      def to_s
        if error.present?
          "#{status} with #{error}"
        else
          "#{status} on #{updated} with #{column_count} columns, #{imported_count} imported and #{invalid_count} invalid"
        end
      end
    end
  end
end
