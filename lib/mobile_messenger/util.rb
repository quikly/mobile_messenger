require 'mobile_messenger/util/parser'
require 'mobile_messenger/util/carriers'

module MobileMessenger
  module Util
    def self.url_encode(hash)
      hash.to_a.map {|p| p.map {|e| CGI.escape e.to_s}.join '='}.join '&'
    end
  end
end
