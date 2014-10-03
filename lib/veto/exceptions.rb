module Veto
  class VetoError < StandardError; end
  class CheckNotAssigned < VetoError; end
  class InvalidEntity < VetoError
    def initialize(errors)
      @errors = errors
    end

    def message
      @errors.full_messages
    end
  end
end