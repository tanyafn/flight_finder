RSpec::Matchers.define :include_itineraries do |*expected_names|

  match do |subject|
    @not_found = []
    expected_names.each do |name|
      ary = name.to_s.upcase.split("_")
      itinerary = subject.select { |i| i.orig == ary[0] && i.dest == ary[1] }
      #itinerary = Itinerary.by_orig(ary[0]).by_dest(ary[1]).first
      @not_found << name if itinerary.blank?
    end
      @not_found.empty?
  end

  failure_message_for_should do |subject|
    "Expected #{@not_found.to_sentence} to be included, but it doesn't."
  end
end
