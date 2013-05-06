require 'spec_helper'
require 'shared_examples/comparison_validator_spec'
require 'shared_contexts/comparison_validator_shared_context'

describe EqualToValidator do
  include_context "comparison validator context"

  it_behaves_like "comparison validator", Thing, :field, :another_field, :equal_to

  describe "validation"  do
    before(:all) { Thing.validates :field, equal_to: :another_field }
    after(:all){ reject_validations(Thing, :field) }

    context "equal fields" do
      before { subject.field = subject.another_field = Time.now }
      specify { subject.should be_valid }
    end

    context "inequal fields" do
      before { subject.field = Time.now; subject.another_field = Time.now + 1.hour }
      it { should be_invalid }

      it "has error message" do
        subject.valid?
        subject.errors[:field].should include(I18n.t("mongoid.errors.models.equal_to", f1: :field, f2: :another_field ))
      end
    end
  end
end