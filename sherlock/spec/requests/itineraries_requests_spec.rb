require 'spec_helper'
require 'shared_contexts/segments_context'

describe ItinerariesController do
  include_context "segments_builder"

  describe "itineraries import" do
    let!(:data) { Fabricate(:itn, segments: build_segments(:pek_bkk)).attributes.except("_id") }

    specify do
      post "/itineraries/import", _json: data
      response.status.should == 200
    end

    specify { -> {post "/itineraries/import", _json: data}.should change(Itinerary, :count).by(1) }

  end

  describe "get clear_all" do
    before { Fabricate(:itn, segments: build_segments(:pek_bkk)) }

    describe "success" do
      before{ get "itineraries/clear_all" }

      specify { Itinerary.count.should == 0 }
      specify { response. should be_ok }
      specify { response.body.should == {deleted: 1}.to_json }
    end

    describe "failure" do
      before{ Itinerary.stub(:destroy_all).and_raise(StandardError) }
      before{ get "itineraries/clear_all" }

      specify { Itinerary.count.should == 1 }
      specify { response.should_not be_ok }
      specify { response.status.should == 500 }
      specify { response.body.should == {deleted: 0}.to_json }
    end
  end

  describe "get all" do
    let!(:itineraries) { Fabricate(:itn, segments: build_segments(:pek_bkk)) }

    describe "success" do
      before { get 'itineraries/all' }

      specify { response.body.should == [itineraries].to_json }
      specify { response. should be_ok }
    end

    describe "failure" do
      before{ Itinerary.stub(:all).and_raise(StandardError) }
      before { get 'itineraries/all' }

      specify { response.body.should =={ errors: Settings.errors.unexpected_error}.to_json }
      specify { response. should_not be_ok }
      specify { response.status.should == 500 }
    end

  end

end