require 'spec_helper'
require 'shared_contexts/segments_context'

describe ItinerariesController do
  include_context "segments_builder"

  describe "get index" do
    describe "valid params" do
      let(:required_params){ {orig: "MOW", dest: "PEK", date: Date.current, format: :json } }
      let(:optional_params){ { stops_count: 1, duration: 36000, price: 600 }.merge(required_params) }

      context "existed itineraries meet search params" do
        let!(:mow_pek){ Fabricate(:itn, segments: build_segments(:mow_kja, :kja_pek)) }

        specify do
          [required_params, optional_params].each do |params|
            get :index, params

            response.body.should == [mow_pek].to_json
            response.should be_ok
          end
        end
      end

      context "no itineraries meet search params" do
        let!(:pek_bkk){ Fabricate(:itn, segments: build_segments(:pek_bkk)) }

        specify do
          [required_params, optional_params].each do |params|
            get :index, params

            response.body.should == "[]"
            response.should be_ok
          end
        end
      end
    end

    describe "invalid params" do
       let(:params){ {orig: "KJA", dest: "KJA", date: Date.current, format: :json } }

       before{ get :index, params }

       specify{ response.should_not be_ok }
    end
  end

  describe "#import" do
    let(:do_post_import){ post :import, _json: json_params, format: :json }

    context "one param" do
      let(:json_params){ { price: 110, segments: build_segments(:kja_pek) } }

      specify { -> { do_post_import }.should change(Itinerary, :count).by(1) }

      describe "response" do
        before { do_post_import }

        specify { response.body.should == { received: 1, saved: 1, rejected: 0 }.to_json }
        specify { response.status.should == 200 }
      end
    end

    context "valid params" do
      let(:json_params){ [{price: 240, segments: build_segments(:kja_pek)}, { price: 160, segments: build_segments(:pek_bkk)}] }

      specify { -> { do_post_import }.should change(Itinerary, :count).by(3) }

      describe "response" do
        before { do_post_import }

        specify { response.body.should == { received: 2, saved: 2, rejected: 0}.to_json }
        specify { response.status.should == 200 }
      end
    end

    context "invalid params" do
     let(:json_params){ [{price: 0, segments: build_segments(:kja_pek)}, { price: 0, segments: build_segments(:pek_bkk)}] }

     specify { ->{ do_post_import }.should_not change(Itinerary, :count) }

     describe "response" do
      before { do_post_import }

      specify { response.status.should == 200 }
      specify { response.body.should == { received: 2, saved: 0, rejected: 2}.to_json }
     end
    end

  end

end
