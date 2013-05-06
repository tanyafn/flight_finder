require 'spec_helper'
require 'shared_contexts/request_mock'

describe SearchesController do
  include_context "request mocks"

  describe "post create" do
    let(:params){ { orig: "KJA", dest: "BKK", date: Date.current, duration: 24, price: 400, stops_count: 1 } }
    let(:search){ mock_model Search, orig: "KJA", dest: "BKK", date: Date.current, attributes: { duration: 24, price: 400, stops_count: 1 } }

    before {  Search.stub(:new).and_return(search) }
    before { mock_get_itineraries(params) }

    it "builds a new search" do
      Search.should_receive(:new)
        .with("orig" => "KJA", "dest" => "BKK", "date" => Date.current.to_s(:db), "duration" => "24", "price" => "400", "stops_count"=> "1")
        .and_return(search)
      post :create, search: params
    end

    it "checks search validity" do
      search.should_receive(:valid?)
      post :create, search: params
    end

    context "valid search params" do
      before { search.stub(:valid?).and_return(true) }

      it "finds itineraries" do
        Itinerary.should_receive(:find_by).with(search)#.and_return(data)
        post :create, search: params
      end

      it "return itineraries" do
        post :create, search: params
        assigns(:itineraries).should have(2).itineraries
        assigns(:itineraries).each{|i| i.orig.should == "KJA"}
      end

      it "renders create template" do
        post :create, search: params
        response.should render_template(:create)
      end
    end

    context "ivalid search params" do
      before { search.stub(:valid?).and_return(false) }

      it "renders new template" do
        post :create, search: params
        response.should render_template(:new)
      end
    end

  end
end
