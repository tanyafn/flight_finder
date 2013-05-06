# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
=begin
10.times do
	Flight.create(orig: Forgery::Basic.text(at_least: 3, at_most: 3, allow_numeric: false, allow_lower:false),
					dest: Forgery::Basic.text(at_least: 3, at_most: 3, allow_numeric: false, allow_lower:false),
					departing_at: Time.now + 3.days, arriving_at: Time.now + 4.days,
					price: Forgery::Monetary.money, duration: 1)
end
=end

