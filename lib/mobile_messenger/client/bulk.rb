module MobileMessenger
  class Client
    module Bulk

      def send_bulk(from, default_message, messages, options = {})
        params = send_bulk_params(from, default_message, messages, options)
        send_job params
      end

      private

      def send_bulk_params(from, default_message, messages, options = {})
        defaults = {
          'action'          => 'CONTENT',
          'receipt-options' => 'DELIVERED',
        }

        params = defaults.merge(options).merge({
          'service-code' => from,
          'recipient-count' => messages.size,
          'message' => {'sms' => default_message },
          'recipients' => messages.collect do |destination, message|
            {
              'r' => {
                'message' => { 'sms' => message },
                'destination' => "tel:#{destination}"
              }
            }
          end
        })

        if params['job-request-id'].nil?
          params['job-request-id'] = generate_job_id
        end

        params
      end
    end
  end
end
