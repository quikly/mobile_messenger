require "mobile_messenger/version"
require 'mobile_messenger/client'
require 'mobile_messenger/errors'
require 'mobile_messenger/util'
require 'mobile_messenger/util/parser'

module MobileMessenger
  # Your code goes here...
  def self.version_string
    "v#{MobileMessenger::VERSION}"
  end
end
