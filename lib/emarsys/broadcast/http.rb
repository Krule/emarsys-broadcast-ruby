require 'net/http'
require 'digest/sha1'
module Emarsys
  module Broadcast
    class HTTP < TransferProtocol
      def initialize(config)
        super config, 'api'
      end

      def post(path, xml)
        request(path, xml, :post)
      end

      def put(path, xml)
        request(path, xml, :put)
      end

      def get(path)
        request(path, nil, :get)
      end

      def delete(path)
        request(path, nil, :delete)
      end

      private

      def construct_request(method, path, data)
        req = select_http_method(method, path)
        req.basic_auth(@config.api_user, Digest::SHA1.hexdigest(@config.api_password))
        req.body = data
        req.content_type = 'application/xml'
        req
      end

      def initialize_request
        https = Net::HTTP.new(@config.api_host, Net::HTTP.https_default_port)
        https.read_timeout = @config.api_timeout
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        https
      end

      def request(path, data, method)
        initialize_request.start do |http|
          res = http.request(construct_request(method, "#{@config.api_base_path}/#{path}", data))
          return res.body if res.is_a?(Net::HTTPSuccess)
          Emarsys::Broadcast.logger.error(HTTP) { res.body }
        end
      end

      def select_http_method(method, path)
        case method.downcase.to_sym
        when :post then Net::HTTP::Post.new(path)
        when :put  then Net::HTTP::Put.new(path)
        when :get  then Net::HTTP::Get.new(path)
        end
      end
    end
  end
end
