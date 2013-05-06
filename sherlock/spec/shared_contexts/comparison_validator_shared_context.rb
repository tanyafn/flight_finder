shared_context "comparison validator context" do
  class Thing
    include ActiveModel::Validations
    attr_accessor :field, :another_field, :third_field
  end

  subject { Thing.new }

   def reject_validations klass, field_name
    klass.class_eval do
      _validators.reject!{ |key, value| key == field_name }
      _validate_callbacks.reject! { |callback| callback.raw_filter.attributes == [field_name] }
    end
  end

end