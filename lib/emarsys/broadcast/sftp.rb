require 'net/sftp'
module Emarsys
  module Broadcast
    class SFTP < TransferProtocol
      def initialize(config)
        super config, 'sftp'
      end

      def upload_file(local_path, remote_path)
        Net::SFTP.start(@config.sftp_host, @config.sftp_user, password: @config.sftp_password) do |sftp|
          sftp.upload!(local_path, remote_path)
        end
      end
    end
  end
end