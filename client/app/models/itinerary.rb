class Itinerary < ActiveResource::Base
  self.site = Settings[Rails.env.to_sym].site_uri

  def self.find_by search
    url = Settings.itineraries_uri % { orig: search.orig, dest: search.dest, date: search.date }
    params = search.attributes.slice(:price, :duration, :stops_count).delete_if{|_, v| v.blank?}
    params[:duration] = params[:duration].to_i * 3600 if params.has_key?(:duration)

    find(:all, from: url, params: params)
  end
end