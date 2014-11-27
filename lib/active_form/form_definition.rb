module ActiveForm
  class FormDefinition
    attr_reader :assoc_name

    def initialize(assoc_name, block, options)
      @assoc_name = assoc_name
      @block = block
      @options = options
    end

    def build_for(model)
      if model.class.reflect_on_association(@assoc_name).macro == :has_many
        CollectionForm
      else
        Form
      end.new(@assoc_name, model, @block, @options)
    end
  end
end
