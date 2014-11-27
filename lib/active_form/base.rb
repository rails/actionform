require 'active_form/model_association'
require 'active_form/collection_association'
require 'active_form/associatable'

module ActiveForm
  class Base
    extend Associatable

    # SignupForm.new(user: User.find(params[:user_id]))
    def initialize(models = nil)
      if models.respond_to?(:each)
        assign_attributes(models)
      else
        main_association.instance = models
      end
    end

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        main_association.save
      end
    end

    def submit(params)
      assign_attributes(params)
    end

    mattr_accessor :main_model, instance_writer: false

    delegate :id, :persisted?, :to_model, :to_partial_path, to: :main_association

    class << self
      delegate :attributes, :association_scope, to: :main_association

      def main_association
        @@main_association ||= \
          if main_model
            ModelAssociation.new(main_model)
          else
            raise ArgumentError, "you need to set the main_model for this form," \
              " like self.main_model = :article"
          end
      end

      private
        def main_model
          @main_model ||= name.sub(/Form$/, '')
        end
    end

    private
      def respond_to_missing?(meth, include_private = false)
        main_association.respond_to?(meth)
      end

      def method_missing(meth, *args, &block)
        if main_association.respond_to?(meth)
          main_association.send(meth, *args, &block)
        else
          super
        end
      end

      def main_association
        @@main_association
      end

      def assign_attributes(attributes)
        attributes.each do |key, value|
          self.public_send("#{key}=", value)
        end if attributes
      end
  end
end
