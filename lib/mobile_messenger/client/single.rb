module MobileMessenger
  class Client
    module Single

      def send_sms(from, to, message, options = {})
        defaults = {
          'action' => 'CONTENT',
          'receiptOption' => 'DELIVERED',
        }

        params = defaults.merge(options).merge({
          'serviceCode' => from,
          'destination'  => to,
          'message'      => message
        })

        params['productCode'] = @config[:default_product_code] if params['productCode'].nil?

        send_single params
      end

      private

      def send_single(params)
        host = @config[:sms_host]
        response = post(host, '/wsgw/sendSingle', params)

        parse_send_single_response(response)
      end

      # patch the sendSingle response with a job-status-id and an mqube-id
      # this saves us a an extra trip to query the status URL
      def parse_send_single_response(response)
        r = MobileMessenger::Util::Parser.parse_response(response, ": ")
        if r.has_key?("StatusURL") && (ids = status_url_to_ids(r["StatusURL"]))
          r.merge!(ids)
        end
        r
      end

    end
  end
end
