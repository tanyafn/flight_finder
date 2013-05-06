require 'spec_helper'
require 'shared_examples/comparison_validator_spec'
require 'shared_contexts/comparison_validator_shared_context'

describe InequalToValidator  do
  include_context "comparison validator context"

  it_behaves_like "comparison validator", Thing, :field, :another_field, :inequal_to

  describe "inequality validation" do
    before(:all){ Thing.validates :field, inequal_to: :another_field }
    after(:all) { reject_validations(Thing, :field) }

    context "equal fields" do
      before { subject.field = subject.another_field = Time.now }
      it { should be_invalid }
    end

    context "inequal fields" do
      before { subject.field = ?A }
      before { subject.another_field = ?B }
      it { should be_valid }
    end
  end

end