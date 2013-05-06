class Segment
  include Mongoid::Document
  include ValidationHelpers
  embedded_in :segmentable

  field :orig, type: String
  field :dest, type: String
  field :arriving_at, type: Time
  field :departing_at, type: Time
  field :number, type: Integer

  validates_presence_of :orig, :dest, :departing_at, :arriving_at
  validates :orig, inequal_to: :dest
  validates :departing_at, less_than: :arriving_at
  validates :orig, :dest, format: { with: /\A[A-Z]{3}\Z/, message: I18n.t("mongoid.errors.models.iata_format") }
  validates :orig, uniqueness: true
  validates :dest, uniqueness: true
end
