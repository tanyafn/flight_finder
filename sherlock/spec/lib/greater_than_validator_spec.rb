require 'spec_helper'
require 'shared_examples/comparison_validator_spec'
require 'shared_contexts/comparison_validator_shared_context'

describe GreaterThanValidator do
  include_context "comparison validator context"

  it_behaves_like "comparison validator", Thing, :field, :another_field, :greater_than

  describe "validation"  do
    before(:all) { Thing.validates :field, greater_than: Proc.new { |obj| obj.another_field } }
    after(:all){ reject_validations(Thing, :field) }

    context "equal fields" do
      before { subject.field = subject.another_field = Time.now }
      it { should be_invalid }
    end

    context "validated field less than another" do
      before { subject.field = 10; subject.another_field = 12 }
      it { should be_invalid }
    end

    context "validated field greater than another" do
      before { subject.field = Time.now + 1.hour; subject.another_field = Time.now }
      it { should be_valid }
    end
  end
end