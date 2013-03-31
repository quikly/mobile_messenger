require 'rexml/document'
require 'shellwords'

module MobileMessenger
  module Util
    class Parser
  
      # There are a few different types of responses
      # sendJob responds with 
      def self.parse_response(response, separator = '=')
        Hash[response.split(/\r?\n/).map {|it| it.split(separator, 2)}]
      end

      # lets look into https://github.com/jnunemaker/happymapper, nokogiri, or https://github.com/jordi/xml-object
      def self.parse_xml_response(response)
        begin
          doc = REXML::Document.new response
          job_report = doc.root
        rescue
          raise MobileMessenger::XMLError
        end
        job_report
      end
    end
  end
end