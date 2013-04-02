#$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'mobile_messenger'
require 'rspec'
require 'webmock/rspec'

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

def send_single_params
  {
    destination: '5008885555',
    serviceCode: '12345',
    message: 'A giraffe goes into a bar',
    productCode: 'ACMEX_12345_JOKE_199_S',
    notificationURL: 'http://mysite.com/sms/jobComplete.jsp',
    receiptOption: 'DELIVERED',
  }
end

def send_job_params
  {
    'job-request-id' => 'abc234354659234',
    'service-code' => '12345',
    'receipt-options' => 'DELIVERED',
    'notification-url' => 'http://mysite.com/jobComplete.jsp',
    'recipient-count' => '3',
    'message' => {
      'sms' => 'Two guys go into a bar...',
    },
    'product-code' => 'ACMEX_12345_JOKE_999_S',
    'action' => 'CONTENT',
    'recipients' => [
      { 'r' => {'destination' => 'tel:6175551000'}},
      { 'r' => {'destination' => 'tel:6175551001'}},
      { 'r' => {
          'destination' => 'tel:6175551002',
          'message' => {
            'sms' => 'A giraffe goes into a bar...',
          }, 
          'product-code' => 'ACMEX_12345_JOKE_199_S',
        }
      }
    ]
  }
end
  
def sms_host
  "sendsms.mobilemessenger.com"
end

def ws_host
  "ws.mobilemessenger.com"
end
  
def stub_post(host, path)
  stub_request(:post, "https://username:password@#{host}#{path}")
end

def stub_get(host, path)
  stub_request(:get, "https://username:password@#{host}#{path}")
end