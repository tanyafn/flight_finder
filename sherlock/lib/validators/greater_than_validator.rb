class GreaterThanValidator < ComparisonValidator

  def initialize(options)
    @operator = :>
    super
  end

end