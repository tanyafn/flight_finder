require 'spec_helper'
require 'shared_contexts/request_mock'

describe Itinerary do
  include_context "request mocks"

  describe "#find_by" do
    before { mock_get_itineraries(params) }
    subject{ Itinerary.find_by(Search.new(params)) }

    context "required search params" do
      let(:params){ {orig: "KJA", dest: "BKK", date: Date.current} }
      it{ should have(2).itineraries }
    end

    context "required params with filters" do
      let(:params){ {orig: "KJA", dest: "BKK", date: Date.current, duration: 24, price: 400, stops_count: 1} }
      it{ should have(2).itineraries }
    end

  end
end