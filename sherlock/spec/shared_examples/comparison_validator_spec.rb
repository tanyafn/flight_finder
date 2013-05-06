shared_examples_for "comparison validator" do |klass, field, another_field, validator|

  after(:each) { reject_validations(klass, field) }

  context "wrong options" do
    specify { -> { klass.validates field, validator => true }.should raise_error(ArgumentError, "options can not be blank") }
    specify { -> { klass.validates field, validator => 1 }.should raise_error(ArgumentError, "with must be a string, a symbol or a proc") }
    specify { -> { klass.validates field, validator => "" }.should raise_error(ArgumentError, "with value must be a non-empty") }
    specify { -> { klass.validates field, validator => :non_existing_field ; subject.valid? }.should raise_error(ArgumentError, "Impossible to evaluate non_existing_field") }
  end

  context "correct options" do
    specify { -> { klass.validates :field, validator => another_field.to_s }.should_not raise_error }
    specify { -> { klass.validates :field, validator => Proc.new { |r| r.send(another_field )} }.should_not raise_error }
  end

end