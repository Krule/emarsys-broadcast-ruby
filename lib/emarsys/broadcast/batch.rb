module Emarsys
  module Broadcast
    class Batch < BatchMailing
      def initialize(attributes = {})
        Broadcast.logger.warn(Batch) do
          ['[deprecated] in favor of', BatchMailing].join(' ')
        end
        super(attributes)
      end
    end
  end
end
