require 'uri'
require 'net/http'
require 'json'
require 'active_support/all'

def get_flights_json
  flights = [[:pek_bkk, 5], [:pek_hkg, 3.5], [:pek_sha, 3], [:pek_gmp, 2], [:gmp_hnd, 2], [:gmp_kix, 2.5], [:gmp_tsa, 4.5], [:gmp_sha, 3], [:hnd_kix, 2],
             [:hkg_sha, 1], [:hkg_tsa, 1.5], [:hkg_kix, 3], [:hkg_mnl, 1.5], [:hkg_dps, 4], [:hkg_jkt, 4], [:hkg_sin, 3], [:hkg_sgn, 2], [:hkg_bkk, 4],
             [:jkt_dps, 1], [:kla_bkk, 2], [:kla_sgn, 2.5], [:kla_sin, 2], [:kla_jkt, 3], [:kla_hkg, 3.5] ]
  time = Date.current.to_time_in_current_zone

  prev_orig = nil
  result = flights.flat_map do |flight|
    (orig, dest) = flight[0].to_s.upcase.split(?_)
    duration = flight[1]
    price = 82 * duration

    build_flights(price, orig, dest, duration)
  end
  result.to_json
end

def build_segments orig, dest, departing_at, duration
  arriving_at = departing_at + duration.hours
  return [{ orig: orig, dest: dest, departing_at: departing_at, arriving_at: arriving_at }]
end

def build_flights price, orig, dest, duration
  flights = (0..2).flat_map do |i|
      d = Date.current + i.days
      hour = rand(6..19)
      mins = (rand(1..6))*5
      departing_at = Time.zone.local(d.year, d.month, d.mday, hour, mins)
      return_departing_at = departing_at + duration.hours + 1.hour
      [{ price: price + rand(10..100), segments: build_segments(orig, dest, departing_at, duration) },
        { price: price + rand(10..100), segments: build_segments(dest, orig, return_departing_at, duration) }]
    end
end

Time.zone = "Asia/Bangkok"
#uri  = URI.parse('http://localhost:3000/itineraries/import')
uri  = URI.parse('http://guarded-springs-8439.herokuapp.com/itineraries/import')

http = Net::HTTP.new(uri.host, uri.port)
http.read_timeout = nil
http.start do |http|
  headers = { "Content-Type" => "application/json", "Accepts" => "application/json" }
  a = Time.now
  puts a
  http.post(uri.request_uri, get_flights_json, headers)
  puts (Time.now - a).to_s
end