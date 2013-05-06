require 'spec_helper'
require 'shared_examples/segment_spec'
require 'shared_examples/segmentable_spec'
require 'shared_contexts/segments_context'

describe Itinerary do
  include_context "segments_builder"

  before { Timecop.freeze(Time.zone.now) }
  after { Timecop.return }

  it { should be_mongoid_document }
  it { should embed_many :segments }

  describe "fields" do
    it { should have_field(:price).of_type(Float) }
    it { should have_fields(:duration, :stops_count).of_type(Integer) }
    it { should have_field(:date).of_type(Date) }
  end

  describe "validations" do
    subject(:itinerary) { Fabricate(:itn, segments: build_segments(:kja_pek, :pek_bkk)) }

    before { itinerary.stub(:calculate_fields) }

    it {[:date, :stops_count, :price, :duration].each { |field| should validate_presence_of(field) }}
    it { should validate_numericality_of(:duration).greater_than(Settings.min_duration).less_than_or_equal_to(Settings.max_duration) }
    it { should validate_numericality_of(:price).greater_than(Settings.min_price).less_than_or_equal_to(Settings.max_price) }
    it { should validate_uniqueness_of(:orig).scoped_to(:dest, :arriving_at, :departing_at) }

    it_behaves_like "a segment of flight"
    it_behaves_like "a segmentable object"
  end

  describe "#filter_by" do
    let!(:mow_pek){ Fabricate(:itn, segments: build_segments(:mow_kja, :kja_pek)) }
    let(:search){ Search.new( orig: "MOW", dest: "PEK", date: Date.current) }

    subject(:search_results){ Itinerary.filter_by(search) }

    describe "required params" do
      it { should == [mow_pek] }

      specify "non-existing orig" do
        search.orig = "GVA"
        search_results.should be_empty
      end

      context "non-existing dest" do
        before { search.dest = "GVA" }
        it { should be_empty }
      end

      context "non-existing date" do
        before { search.date = Date.yesterday }
        it { should be_empty }
      end
    end

    describe "optional params" do
      describe "price" do
        context "suitable expected price" do
          before { search.price = 400 }
          it { should == [mow_pek] }
        end

        context "expected price is higher then existed" do
          before { search.price = 600 }
          it { should == [mow_pek] }
        end

        context "expected price is lower then existed" do
          before { search.price = 100 }
          it { should be_empty }
        end
      end

      describe "duration" do
        context "expected duration is equal to existed" do
          before { search.duration = 10.hours }
          it { should == [mow_pek] }
        end

        context "expected duration is more then existed" do
          before { search.duration = 11.hours }
          it { should == [mow_pek] }
        end

        context "expected duration is less then existed" do
          before { search.duration = 6.hours }
          it { should be_empty }
        end
      end

      describe "stops_count" do
        context "expected stops count is equal to existed" do
          before { search.stops_count = 1 }
          it { should == [mow_pek] }
        end

        context "expected price is higher then existed" do
          before { search.stops_count = 2 }
          it { should == [mow_pek] }
        end

        context "expected price is lower then existed" do
          before { search.stops_count = 0 }
          it { should be_empty }
        end
      end
    end
  end

  describe "#calculate_fields" do
    subject { Itinerary.create( segments: build_segments(:mow_kja, :kja_pek)) }

    its(:orig) { should == "MOW" }
    its(:dest) { should == "PEK" }
    its(:departing_at) { should == Time.zone.now }
    its(:arriving_at) { should == 10.hours.from_now }
    its(:date) { should == Date.current }
    its(:duration) { should == 10.hours }
    its(:stops_count) { should == 1 }
  end

  describe "#find_incomings_to" do
    let(:mow_pek) { Fabricate(:itn, segments: build_segments(:mow_kja, :kja_pek)) }
    let(:params) {{ place: "PEK", min_time: mow_pek.arriving_at - 1.hour, max_time: mow_pek.arriving_at + 1.hour, stops_count: 3 }}

    subject(:found_incomings) do
      Itinerary.find_incomings_to(params[:place], params[:stops_count], params[:min_time], params[:max_time])
    end

    specify { found_incomings.should == [mow_pek] }

    specify "incomings arrival time less then param's min_time" do
      params[:min_time] = mow_pek.arriving_at + 1.hour
      found_incomings.should be_empty
    end

    specify "incomings arrival time equal to param's min_time" do
      params[:min_time] = mow_pek.arriving_at
      found_incomings.should == [mow_pek]
    end

    specify "incomings arrival time greater then param's max_time" do
      params[:max_time] = mow_pek.arriving_at - 1.hour
      found_incomings.should be_empty
    end

    specify "incomings arrival time equal to param's max_time" do
      params[:max_time] = mow_pek.arriving_at
      found_incomings.should == [mow_pek]
    end

    specify "incomings stops_count greater then or equal to params stops_count" do
      [mow_pek.stops_count - 1, mow_pek.stops_count].each do |count|
        params[:stops_count] = count
        found_incomings.should be_empty
      end
    end

    specify "incomings orig not equla to params place" do
      params[:place] = "KLA"
      found_incomings.should be_empty
    end
  end

  describe "#find_outgoings_from" do
    let(:mow_pek) { Fabricate(:itn, segments: build_segments(:mow_kja, :kja_pek)) }
    let(:params) {{ place: "MOW", min_time: mow_pek.departing_at - 1.hour, max_time: mow_pek.departing_at + 1.hour, stops_count: 3 }}

    subject(:found_outgoings) do
      Itinerary.find_outgoings_from(params[:place], params[:stops_count], params[:min_time], params[:max_time])
    end

    specify { found_outgoings.should == [mow_pek] }

    context "outgoings departure time less then param's min_time" do
      before { params[:min_time] = mow_pek.departing_at + 1.hour }
      specify { found_outgoings.should be_empty }
    end

    context "outgoings departure time equal to param's min_time" do
      before { params[:min_time] = mow_pek.departing_at }
      specify { found_outgoings.should == [mow_pek] }
    end

    context "outgoings departure time greater then param's max_time" do
      before { params[:max_time] = mow_pek.departing_at - 1.hour }
      specify { found_outgoings.should be_empty }
    end

    context "outgoings departure time equal to param's max_time" do
      before { params[:max_time] = mow_pek.departing_at }
      specify { found_outgoings.should == [mow_pek] }
    end

    specify "outgoings stops_count greater then or equal to params stops_count" do
      [mow_pek.stops_count - 1, mow_pek.stops_count].each do |count|
        params[:stops_count] = count
        found_outgoings.should be_empty
      end
    end

    context "outgoings orig not equal to params place" do
      before { params[:place] = "KLA" }
      specify { found_outgoings.should be_empty }
    end
  end

end
