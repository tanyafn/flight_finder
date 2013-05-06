class Search
  include ActiveModel::Validations

   def self.typesafe_accessor(accessor_name, type)
    define_method(accessor_name) do
      instance_variable_get("@#{accessor_name}")
    end

    define_method("#{accessor_name}=") do |value|
      v = if value.is_a?(type)
        value
      else
        (value.blank?) ? nil : "#{type.name}Converter".constantize.parse(value)
      end
      instance_variable_set("@#{accessor_name}", v)
    end
  end

  def initialize(attributes = {})
      attributes.each { |key, value| send("#{key}=", value) }
      @attributes = attributes
  end

  attr_accessor :attributes
  typesafe_accessor :orig, String
  typesafe_accessor :dest, String
  typesafe_accessor :date, Date
  typesafe_accessor :duration, Integer
  typesafe_accessor :price, Integer
  typesafe_accessor :stops_count, Integer

  validates_presence_of :orig, :dest, :date
  validates :orig, inequal_to: :dest
  validates :orig, :dest, format: { with: /\A[A-Z]{3}\Z/, message: "only 3 letters are allowed" }
  validates_date :date, on_or_after: lambda { Date.current }, on_or_before: lambda { Date.current + 1.year }
  validates_numericality_of :stops_count, greater_than_or_equal_to: Settings.min_stops_count, less_than_or_equal_to: Settings.max_stops_count, only_integer: true, allow_blank: true
  validates_numericality_of :price, greater_than: Settings.min_price, less_than_or_equal_to: Settings.max_price, only_integer: true, allow_blank: true
  validates_numericality_of :duration,  greater_than: Settings.min_duration, less_than_or_equal_to: Settings.max_duration, only_integer: true, allow_blank: true

end
