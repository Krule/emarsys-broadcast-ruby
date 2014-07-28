module Emarsys
  module Broadcast
    class BatchMailing < BaseMailing
      attr_accessor :import_delay_hours,
                    :recipients_path,
                    :send_time

      validates :recipients_path, presence: true
    end
  end
end
