module ActiveForm
  concern :Associatable do
    def association(name, options = {})
      association = child_class_for(options).new(name, options)
      association_scope.add_child(association, Proc.new)
      define_association_accessors(name, association)
    end

    def association_scope
      self
    end

    private
      def child_class_for(options)
        options.key?(:records) ? CollectionAssociation : ModelAssociation
      end

      def define_association_accessors(name, association)
        class_eval do
          define_method(name) { association }
          define_method("#{name}=") { |i| association.instance = i }
          define_method("#{name}_attributes=") do |attrs|
            association.attributes = attrs
          end
        end
      end
  end
end
