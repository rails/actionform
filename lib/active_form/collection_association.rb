require 'active_form/model_association'

module ActiveForm
  class CollectionAssociation < ModelAssociation
    def initialize(model_name, options)
      super
      @instances = []
    end

    def dynamic?
      true # means we can add more instances in a form
    end

    def records
      size
    end

    delegate :each, :size, :[], to: :@instances

    # Map model attributes by key to association
    # doghouse_attributes: { '1' => { name: 'McDiniis' }, '2' => { name: 'McDunuus' } }
    def attributes=(model_attributes)
      model_attributes.each do |model_id, attrs|
        fetch_instance(model_id.to_i).attributes = attrs
      end
    end

    def build_instance
      model_class.new.tap { |i| @instances << i }
    end

    private
      def fetch_instance(id)
        @instances[id] || build_instance
      end
  end
end
