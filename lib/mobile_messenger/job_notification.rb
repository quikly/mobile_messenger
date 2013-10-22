module MobileMessenger
  class JobCompleteNotification
    def self.process(params = {}, &block)
      process_notification params.except(:controller, :action), &block
    end
    
    # The original Hash of attributes received from SendGrid.
    attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes.with_indifferent_access
    end
    
    def [](key)
      attributes[key]
    end
    
    def success_response
      "JobRequestID=#{@attributes['JobRequestID']}\nmQubeID=#{@attributes['mQubeID']}"
    end
    
    class << self
      private

      def process_notification(params, &processor)
        processor.call JobCompleteNotification.new(params)
      end
    end

  end
end
