class LessThanValidator < ComparisonValidator
  def initialize(options)
    @operator = :<
    super
  end
end