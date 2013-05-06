class ItinerariesController < ApplicationController
  respond_to :json

  rescue_from StandardError, with: :handle_unexpected_error
  rescue_from SearchParamsError, with: :handle_invalid_params

  def index
    attrs = params.slice(:orig, :dest, :date, :duration, :stops_count, :price)
    search = Search.new(attrs)
    raise SearchParamsError if search.invalid?

    @itineraries = Itinerary.filter_by(search)
    respond_with @itineraries
  end

  def import
    @itineraries_attrs = Array.wrap(params[:_json])

    rejected = @itineraries_attrs.inject(0) do |rejected, attrs|
      itinerary = Itinerary.new(attrs.slice("price", "segments"))
      itinerary.valid? ? ItineraryBuilder.new.build(itinerary) : rejected += 1
      rejected
    end
    render json: { received: @itineraries_attrs.size, saved: @itineraries_attrs.size - rejected, rejected: rejected }
  end

  def clear_all
    count = Itinerary.count
    Itinerary.destroy_all
    render json: { deleted: count }, status: 200
    rescue
      render json: { deleted: 0 }, status: 500
  end

  def get_all
    respond_with Itinerary.all.asc(:stops_count, :orig)
  end

  private

  def handle_invalid_params
    render json: { errors: Settings.errors.invalid_params }, status: :bad_request
  end

  def handle_unexpected_error
    render json: {errors: Settings.errors.unexpected_error}, status: 500
  end
end