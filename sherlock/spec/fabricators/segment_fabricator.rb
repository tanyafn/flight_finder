Fabricator(:mow_kja, from: :segment)  do
  orig "MOW"
  dest "KJA"
  departing_at { Time.zone.now  }
  arriving_at { |s| s[:departing_at] + 4.hours }
  number 0
end

Fabricator(:kja_pek, from: :segment)  do
  orig "KJA"
  dest "PEK"
  departing_at { Time.zone.now + 6.hours }
  arriving_at { |s| s[:departing_at] + 4.hours }
  number 0
end

Fabricator(:pek_bkk, from: :segment)  do
  orig "PEK"
  dest "BKK"
  departing_at { Time.zone.now + 12.hours }
  arriving_at { |s| s[:departing_at] + 5.hours }
  number 0
end

Fabricator(:bkk_kla, from: :segment)  do
  orig "BKK"
  dest "KLA"
  departing_at { Time.zone.now + 19.hours }
  arriving_at { |s| s[:departing_at] + 2.hours }
  number 0
end

Fabricator(:kla_syd, from: :segment)  do
  orig "KLA"
  dest "SYD"
  departing_at { Time.zone.now + 23.hours }
  arriving_at { |s| s[:departing_at] + 7.hours }
  number 0
end