module MobileMessenger
  class Client
    module Bulk

      def send_bulk(from, default_message, messages, options = {})
        params = send_bulk_params(from, default_message, messages, options)
        send_job params
      end

      def send_multiple(from, recipients, message, options = {})
        params = send_multiple_params(from, recipients, message, options)
        send_job params
      end

      def check_job_status(job_id)
        host = @config[:ws_host]
        response = get(host, '/wsgw/checkJobStatus', { 'JobRequestID' => job_id })
        if response == 'INVALID'
          false
        else
          parse_send_job_response(response)
        end
      end

      def get_job_status_report(path)
        get_external_xml(path)
      end

      def get_job_receipt_report(path)
        get_external_xml(path)
      end

      def get_job_config
        host = @config[:ws_host]
        MobileMessenger::Util::Parser.parse_response(get(host, '/wsgw/getJobConfig'), "=")
      end

      private

        def send_job(params)
          host = @config[:sms_host]
          parse_send_job_response(post(host, '/wsgw/sendJob', {
            'JobXML' => send_job_params_to_xml(params)
          }))
        end

        def parse_send_job_response(response)
          MobileMessenger::Util::Parser.parse_response(response, "=")
        end

        def send_bulk_params(from, default_message, messages, options = {})
          options = default_options(options)
          options.merge({
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
        end

        def send_multiple_params(from, recipients, message, options = {})
          options = default_options(options)
          options.merge({
            'service-code' => from,
            'recipient-count' => recipients.uniq.size,
            'message' => {'sms' => message},
            'recipients' => recipients.uniq.map { |x| {'r' => {'destination' => "tel:#{x}"}} }
          })
        end

        def default_options(options = {})
          options['action']          ||= 'CONTENT'
          options['receipt-options'] ||= 'DELIVERED'
          options['job-request-id']  ||= generate_job_id
          options
        end
    end
  end
end
