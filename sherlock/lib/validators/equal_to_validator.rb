class EqualToValidator < ComparisonValidator

  def initialize(options)
    @operator = :==
    super
  end

end