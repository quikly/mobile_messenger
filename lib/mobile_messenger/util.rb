#require 'cgi'

module MobileMessenger
  module Util
    def url_encode(hash)
      hash.to_a.map {|p| p.map {|e| CGI.escape e.to_s}.join '='}.join '&'
    end    
    # def self.url_encode(params)
    #   params.map{|k,v| "#{CGI::escape(k.to_s)}=#{CGI::escape(v)}"}.join('&')
    # end
  end
end