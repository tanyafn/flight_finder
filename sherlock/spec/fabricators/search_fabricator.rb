Fabricator :required_params, class_name: :search do
  orig { sequence(:orig){ |i| i.times.inject('AAA'){ |code| code.next } } }
  dest { sequence(:dest){ |i| i.times.inject('NNN'){ |code| code.next } } }
  date { Date.tomorrow}
end

Fabricator :optional_params, from: :required_params do
  stops_count { Forgery::Basic.number(at_least:0, at_most: 3) }
  duration { Forgery::Basic.number(at_least:1, at_most: 48) }
  price { Forgery::Monetary.money(min:1, max: 4000) }
end

Fabricator :required_kja_bkk_params, from: :required_params do
  orig "KJA"
  dest "BKK"
  date { Date.tomorrow }
end

Fabricator :optional_kja_bkk_params, from: :required_kja_bkk_params do
  stops_count 1
  duration 12
  price 600
end