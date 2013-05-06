require 'spec_helper'

shared_examples_for "a segment of flight" do
  describe "fields" do
    it { should have_fields(:orig, :dest).of_type(String) }
    it { should have_fields(:departing_at, :arriving_at).of_type(Time) }
  end

  describe "validation" do
    it { [:orig, :dest, :arriving_at, :departing_at].each {|field| should validate_presence_of(field) } }
    it { should validate_that(:orig).inequal_to(:dest) }
    it { should validate_that(:departing_at).less_than(:arriving_at) }

    [:orig, :dest].each do |field|
        it { should validate_format_of(field).to_allow("KJA") }
        it { ["kja", "RJ", "Krasnoyarsk", 1, "123"].each { |v| should validate_format_of(field).not_to_allow(v) } }
    end
  end
end