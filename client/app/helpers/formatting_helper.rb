module FormattingHelper
  def timespan_in_words timespan
    %w(day hour minute).inject("") do |str, interval|
      num = timespan/1.send(interval)
      timespan -= num.send(interval)
      str += "#{num}#{interval[0]}" + " " if num > 0
      str
    end
  end

  def flight_caption from, to
    (city_by_iata(from) + "&thinsp;&rarr;&thinsp;" + city_by_iata(to)).html_safe
  end

  def flight_segment_info from, to, departing_at, arriving_at
    (city_by_iata(from) + "&ensp;" + Time.zone.parse(departing_at).strftime("%d %b, %H:%M") + "&emsp;&rsaquo;&emsp;" +
      city_by_iata(to) + "&ensp;" + Time.zone.parse(arriving_at).strftime("%d %b, %H:%M")).html_safe
  end

  def stopovers_info segments
     segments.size > 1 ? get_stopovers_string(segments) : Settings[:non_stop]
  end

  private

  def get_stopovers_string segments
    stops_str = segments.flat_map { |s| s.dest }.take(segments.size-1).join(", ")
    pluralize(segments.size - 1, "stop") + " " + "(#{stops_str})"
  end

  def city_by_iata iata
    Settings.cities.to_hash.key(iata).to_s
  end

end