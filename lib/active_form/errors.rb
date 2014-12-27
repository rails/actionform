module ActiveForm
  class TooManyRecords < RuntimeError;end

  class AttributeAssignmentError < RuntimeError
    attr_reader :exception, :attribute
    def initialize(message, exception, attribute)
      super(message)
      @exception = exception
      @attribute = attribute
    end
  end

  # Raised when there are multiple errors while doing a mass assignment through the +attributes+
  # method. The exception has an +errors+ property that contains an array of AttributeAssignmentError
  # objects, each corresponding to the error while assigning to an attribute.
  class MultiparameterAssignmentErrors < RuntimeError
    attr_reader :errors
    def initialize(errors)
      @errors = errors
    end
  end
end
