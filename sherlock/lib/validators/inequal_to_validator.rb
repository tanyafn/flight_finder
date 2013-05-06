class InequalToValidator < ComparisonValidator

  def initialize(options)
    @operator = :!=
    super
  end

end
