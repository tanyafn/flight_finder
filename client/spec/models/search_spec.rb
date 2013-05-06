require 'spec_helper'

describe Search do
  describe "#initialize" do
      subject { Search.new(orig: "BKK", dest: "KJA", date: Date.current, price: 150, stops_count: 1, duration: 72) }
      it { should be_valid }
      its(:orig){ should == "BKK" }
      its(:dest){ should == "KJA" }
      its(:date){ should == Date.current }
      its(:price){ should == 150 }
      its(:stops_count){ should == 1 }
      its(:duration){ should == 72 }

    describe "attributes" do
      let(:params){ { orig: "GVA", dest: "MOW", date: Date.current.to_s(:db), price: 150, stops_count: 1, duration: 72 } }
      subject { Search.new(params) }
      its(:attributes) { should == params }
    end
  end

  describe "validation" do
    [:orig, :dest, :date].each { |field| it { should validate_presence_of(field) } }

    [:orig, :dest].each do |field|
      it { should allow_value("BKK").for(field) }
      it { ["kja", "RJ", "Krasnoyarsk", 1, "123"].each { |v| should_not allow_value(v).for(field) } }
    end

    describe "date" do
      let(:invalid_dates){ [Date.current - 1.day, Date.current.years_since(1) + 1.day, "not a date"] }
      specify { invalid_dates.each { |v| should_not allow_value(v).for(:date) }}

      let(:valid_dates){ [Date.current, Date.current.years_since(1), Date.current.to_s(:db)] }
      specify { valid_dates.each { |v| should allow_value(v).for(:date) }}
    end

    [:duration, :stops_count, :price].each do |field|
      context field do
        let(:min_val){ Settings.send("min_#{field}") }
        let(:max_val){ Settings.send("max_#{field}") }

        let(:invalid_values){ [min_val - 1, max_val + 1, 0.5 + min_val, "not int"] }
        specify { invalid_values.each { |v| should_not allow_value(v).for(field) }}

        let(:valid_values){ [min_val, max_val, min_val.to_s] }
        specify { valid_values.each { |v| should allow_value(v).for(field) }}

        it { should allow_value(nil).for(field) }
        it { should validate_numericality_of(field) }
      end
    end
  end

end