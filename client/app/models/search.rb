class Search
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  attr_accessor *(ATTRS = %w(orig dest date duration stops_count price))

  validates_presence_of :orig, :dest, :date
  validates :orig, :dest, format: { with: /\A[A-Z]{3}\Z/, message: "only 3 letters are allowed" }
  validates_date :date, on_or_after: -> { Date.current }, on_or_before: -> { Date.current + 1.year }
  validates :orig, inequality: { to: :dest }
  validates :dest, inequality: { to: :orig }
  validates_numericality_of :stops_count, greater_than_or_equal_to: Settings.min_stops_count, less_than_or_equal_to: Settings.max_stops_count, only_integer: true, allow_blank: true
  validates_numericality_of :price, greater_than_or_equal_to: Settings.min_price, less_than_or_equal_to: Settings.max_price, only_integer: true, allow_blank: true
  validates_numericality_of :duration, greater_than_or_equal_to: Settings.min_duration, less_than_or_equal_to: Settings.max_duration, only_integer: true, allow_blank: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def attributes
    ATTRS.each_with_object({}){ |attr, hsh| hsh[attr.to_sym] = instance_variable_get("@#{attr}") }
  end

  def persisted?
    false
  end
end