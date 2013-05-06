class Itinerary
  include Mongoid::Document
  include ValidationHelpers

  embeds_many :segments, as: :segmentable
  accepts_nested_attributes_for :segments

  before_validation :calculate_fields

  field :orig, type: String
  field :dest, type: String
  field :departing_at, type: Time
  field :arriving_at, type: Time
  field :duration, type: Integer
  field :price, type: Float
  field :stops_count, type: Integer
  field :date, type: Date

  validates_presence_of :orig, :dest, :date, :departing_at, :arriving_at, :stops_count, :duration, :price
  validates_format_of :orig, :dest, with: /\A[A-Z]{3}\Z/, message: I18n.t("mongoid.errors.models.iata_format")
  validates_numericality_of :duration, greater_than: Settings.min_duration, less_than_or_equal_to: Settings.max_duration
  validates_numericality_of :price, greater_than: Settings.min_price, less_than_or_equal_to: Settings.max_price
  validates_numericality_of :stops_count, greater_than_or_equal_to: Settings.min_stops_count, less_than_or_equal_to: Settings.max_stops_count
  validates :orig, uniqueness: { scope: [:dest, :arriving_at, :departing_at] }

  validates :orig, inequal_to: :dest
  validates :departing_at, less_than: :arriving_at

  #segmentable validation
  validates :orig, equal_to: Proc.new { |o| o.segments.first.orig}
  validates :dest, equal_to: Proc.new { |o| o.segments.last.dest }
  validates :departing_at, equal_to: Proc.new { |o| o.segments.first.departing_at}
  validates :arriving_at, equal_to: Proc.new { |o| o.segments.last.arriving_at }
  validates :stops_count, equal_to: Proc.new { |o| o.segments.size - 1 }
  #validates :duration, equal_to: Proc.new { |o| o.segments.first.departing_at - o.segments.last.arriving_at }

  scope :by_orig, lambda { |orig| where orig: orig }
  scope :by_dest, lambda { |dest| where dest: dest }
  scope :by_date, lambda { |date| where date: date }

  scope :by_stops_count, lambda { |sc| where :stops_count.lte => sc }
  scope :by_duration, lambda { |duration| where :duration.lte => duration }
  scope :by_price, lambda { |price| where :price.lte => price }

  def self.find_incomings_to (place, stops, from_time, to_time)
    where(dest: place, :stops_count.lt => stops, :arriving_at.gte => from_time, :arriving_at.lte => to_time).to_a
  end

  def self.find_outgoings_from(place, stops, from_time, to_time)
    where(orig: place, :stops_count.lte => stops, :departing_at.gte => from_time, :departing_at.lte => to_time).to_a
  end

  def self.filter_by(search)
    i = by_orig(search.orig).by_dest(search.dest).by_date(search.date)
    i = i.by_stops_count(search.stops_count) if search.stops_count.present?
    i = i.by_duration(search.duration) if search.duration.present?
    i = i.by_price(search.price) if search.price.present?
    i = i.asc(:stops_count, :price)
    i
  end

  protected

  def calculate_fields
    self.orig = segments.first.orig
    self.dest = segments.last.dest
    self.departing_at = segments.first.departing_at
    self.arriving_at = segments.last.arriving_at
    self.duration = (arriving_at - departing_at).round(0)
    self.stops_count = segments.size - 1
    self.date = departing_at.in_time_zone.to_date
  end

end