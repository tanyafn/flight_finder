require 'spec_helper'

describe ItineraryBuilder do

  describe "#build" do
    before { Timecop.freeze(Time.zone.now) }

    let(:param) { Fabricate.build(:itn, segments: build_segments(:pek_bkk)) }
    let(:saved_param){ Itinerary.find_by(param.attributes.except("_id")) }

    let(:built_itineraries) { subject.build(param) }

    context "no adjacent itineraries exist" do
      specify { built_itineraries.should == [saved_param] }
    end

    context "only incoming adjacent itineraries exist" do
      before { create_incomings! :mow_kja, :kja_pek, [:mow_kja, :kja_pek] }

      specify { built_itineraries.should include_itineraries(:mow_bkk, :kja_bkk, :pek_bkk) }
    end

    context "only outgoing adjacent itineraries exist" do
      before { create_outgoings! :bkk_kla, :kla_syd, [:bkk_kla, :kla_syd] }

      specify { built_itineraries.should include_itineraries(:pek_bkk, :pek_kla, :pek_syd) }
    end

    context "incoming and outgoing adjacent itineraries exist" do
      before do
        create_incomings! :mow_kja, :kja_pek, [:mow_kja, :kja_pek]
        create_outgoings! :bkk_kla, :kla_syd, [:bkk_kla, :kla_syd]
      end

      specify { built_itineraries.should include_itineraries(:mow_bkk, :mow_kla, :kja_bkk, :kja_kla, :kja_syd, :pek_bkk, :pek_kla, :pek_syd) }
    end

    context "param itinerary has max stops count" do
      before { create_outgoings!(:kla_syd) }
      let(:param) { Fabricate.build(:itn, segments: build_segments([:mow_kja, :kja_pek, :pek_bkk, :bkk_kla])) }

      it "doesn't search for adjucent itineraries" do
        Itinerary.should_not_receive(:find_outgoings_to)
        Itinerary.should_not_receive(:find_incomings_to)
        subject.build(param)
      end

      specify { built_itineraries.should == [saved_param] }

    end

    after { Timecop.return }

    def build_segments names
      names = Array.wrap(names)
      names.inject([]){ |ary, segment_name| ary << Fabricate.build(segment_name) }
    end

    def create_incomings! *names
      names.each { |segments| Fabricate(:itn, segments: build_segments(segments)) }
    end

    alias_method :create_outgoings!, :create_incomings!
  end
end

