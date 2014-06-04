require 'rexml/document'
require 'shellwords'

module MobileMessenger
  module Util
    class Parser

      class << self
        # There are a few different types of responses
        # sendJob responds with
        def parse_response(response, separator = '=')
          Hash[response.split(/\r?\n/).map {|it| it.split(separator, 2)}]
        end

        # lets look into https://github.com/jnunemaker/happymapper, nokogiri, or https://github.com/jordi/xml-object
        def parse_xml_response(response)
          begin
            doc = REXML::Document.new response
            root = doc.root
          rescue
            raise MobileMessenger::XMLError
          end
          root
        end

        def to_xml(params)
          params.map do |k, v|
            if Hash === v
              text = MobileMessenger::Util::Parser.to_xml(v)
            elsif Array === v
              text = v.map {|x| MobileMessenger::Util::Parser.to_xml(x)}.join
            else
              text = v.encode(xml: :text)
            end
            "<%s>%s</%s>" % [k, text, k]
          end.join
        end

        def job_and_mqube_id_from_status_url(status_url)
          if m = status_url.match(/\/(?<mqube-id>[a-z0-9]+)-(?<job-request-id>[a-z0-9-]+)\.xml/)
            Hash[m.names.zip(m.captures)]
          end
        end
      end
    end
  end
end
