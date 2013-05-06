require 'spec_helper'

describe "route for getting itineraries" do
  let(:date){ Date.current.strftime('%Y-%m-%d') }

  let(:valid_route){ "/itineraries/MOW/KJA/#{date}.json" }
  let(:invalid_routes){ ["/itineraries", "/itineraries.json", "/itineraries/2013-01-29", "/itineraries/MOW/KJA/"] }

  it { expect(get: valid_route).to route_to(controller: "itineraries", action: "index", orig: "MOW", dest: "KJA", date: date, format: "json") }

  specify { invalid_routes.each {|route| expect(get: route).not_to be_routable } }
end

describe "route for itineraries import" do
  it { expect(post: "/itineraries/import.json").to route_to(controller: "itineraries", action: "import", format: "json") }
  it { expect(get: "/itineraries/import.json").not_to be_routable }
end

describe 'route for itineraries removal' do
  it { expect(get: "/itineraries/clear_all").to route_to(controller: "itineraries", action: "clear_all", format: "json" ) }
end

describe 'route for getting all itineraries' do
  it { expect(get: "/itineraries/all").to route_to(controller: "itineraries", action: "get_all", format: "json" ) }
end