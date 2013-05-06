shared_context "request mocks"  do

  def mock_get_itineraries params
    itineraries = File.read("spec/data/itineraries.json")
    additional_params = params.slice(:price, :duration, :stops_count).delete_if{|_, v| v.blank?}
    additional_params[:duration] = additional_params[:duration].to_i * 3600 if additional_params.has_key?(:duration)

    uri = Settings[Rails.env.to_sym].site_uri + Settings.itineraries_uri % { orig: params[:orig], dest: params[:dest], date: params[:date] }
    uri += "?#{additional_params.to_param}" unless additional_params.empty?

    FakeWeb.register_uri(:get, uri, body: itineraries)
  end

end