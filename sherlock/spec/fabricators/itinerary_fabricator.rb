Fabricator(:itinerary)  do
  orig { sequence(:orig){ |i| i.times.inject('AAA'){ |code| code.next } } }
  dest { sequence(:dest){ |i| i.times.inject('NNN'){ |code| code.next } } }
  date { Date.tomorrow}
  stops_count { Forgery::Basic.number(at_least:0, at_most: 3) }
  duration { Forgery::Basic.number(at_least:1, at_most: 48) }
  price { Forgery::Monetary.money(min:1, max: 4000) }
  after_build{|itinerary| itinerary[:departing_at]= date.to_time + 5.hours }
  after_build {|itinerary| itinerary[:arriving_at]= itinerary[:departing_at] + itinerary[:duration].hours }
end

Fabricator(:kja_mow_itinerary, from: :itinerary) do
  orig {"KJA"}
  dest {"MOW"}
  date { Date.tomorrow }
  stops_count {0}
  duration {4}
  price {300}
  after_build do |i|
    i.segments << Fabricate.build(:segment, orig: i.orig, dest: i.dest, departing_at: i.departing_at, arriving_at: i.arriving_at)
  end
end

Fabricator(:kja_bkk_itinerary, from: :kja_mow_itinerary) do
  dest "BKK"
  duration 8
  price 500
end

Fabricator(:hkg_bkk_itinerary, from: :kja_bkk_itinerary) do
  orig "HKG"
  duration 4
end

Fabricator(:itn, from: :itinerary) do
  after_build do |f|
    f.price = 200 * f.segments.size
  end
end