class ItineraryBuilder

  def build itinerary
    return [] unless itinerary.valid?
    incomings = outgoings = [nil] if itinerary.stops_count >= Settings.max_stops_count

    outgoings ||= find_outgoings(itinerary) << nil
    incomings ||= find_incomings(itinerary) << nil

    itineraries = []
    incomings.each do |i|
      outgoings.each do |o|
        ary = [i, itinerary, o].compact
        price = ary.inject(0){ |price, obj| price += obj.price }
        segments = ary.inject([]){ |segments, obj| segments += tidy_up_attrs(obj.segments) }
        itineraries << Itinerary.create(price: price, segments: segments)
      end
    end
    itineraries
  end

  private

  def find_outgoings itinerary
    available_stops_count = Settings.max_stops_count - itinerary.stops_count
    from_time = itinerary.arriving_at + Settings.min_timespan.hours
    to_time = itinerary.arriving_at + Settings.max_timespan.hours

    Itinerary.find_outgoings_from(itinerary.dest, available_stops_count, from_time, to_time)
  end

  def find_incomings itinerary
    available_stops_count = Settings.max_stops_count - itinerary.stops_count
    from_time = itinerary.departing_at - Settings.max_timespan.hours
    to_time = itinerary.departing_at - Settings.min_timespan.hours

    Itinerary.find_incomings_to(itinerary.orig, available_stops_count, from_time, to_time)
  end

  def tidy_up_attrs objects
    objects.inject([]){ |ary, obj| ary << obj.attributes.except("_id")}
  end
end