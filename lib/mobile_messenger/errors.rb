module MobileMessenger
  class BaseError < StandardError
    attr_reader :code
    def initialize(msg = nil, code = nil)
      @code = code
      super(msg)
    end
  end

  class RequestError < BaseError
  end

  class ServerError < BaseError
  end

  class XMLError < StandardError
  end
end