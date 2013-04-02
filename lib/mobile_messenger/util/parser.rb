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
          root = doc.root
        rescue
          raise MobileMessenger::XMLError
        end
        root
      end
      
      def self.to_xml(params)
        params.map do |k, v|
          if Hash === v
            text = MobileMessenger::Util::Parser.to_xml(v)
          elsif Array === v
            text = v.map {|x| MobileMessenger::Util::Parser.to_xml(x)}.join
          else
            text = v
          end
          "<%s>%s</%s>" % [k, text, k]
        end.join
      end
    end
  end
end