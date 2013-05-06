require 'spec_helper'

describe Search do

  [:orig, :dest, :date].each do|field|
    it { should validate_presence_of(field) }
  end

  [:duration, :price, :stops_count].each do |field|
    it { should allow_value(nil).for(field) }
  end

  describe "orig and dest field" do
    [:orig, :dest].each do |field|
      it { should allow_value("BKK").for(field) }
      it { ["kja", "RJ", "Krasnoyarsk", 1, "123"].each { |v| should validate_format_of(field).not_to_allow(v) } }
    end

    it { should validate_that(:orig).inequal_to(:dest)}
  end

  describe "date field" do
    it { should_not allow_value(Date.yesterday).for(:date) }
    it { should_not allow_value(Date.current + 2.years).for(:date) }
    it { should allow_value(Date.current + 1.month).for(:date) }
  end
  it { should validate_numericality_of(:duration).only_integer(true).greater_than(Settings.min_duration).less_than_or_equal_to(Settings.max_duration) }
  it { should validate_numericality_of(:price).only_integer(true).greater_than(Settings.min_price).less_than_or_equal_to(Settings.max_price) }
  it { should validate_numericality_of(:stops_count).only_integer(true).greater_than_or_equal_to(Settings.min_stops_count).less_than_or_equal_to(Settings.max_stops_count) }
end
