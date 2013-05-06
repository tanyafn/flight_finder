RSpec::Matchers.define :validate_that do |first_attr|

  match do |model|
    @model = model
    @first_attribute = first_attr
    send(@chain_method.to_sym)
  end

  chain :greater_than do |second_attr|
    @second_attribute = second_attr
    @chain_method = :match_greater_than
  end

  chain :less_than do |second_attr|
    @second_attribute = second_attr
    @chain_method = :match_less_than
  end

  chain :equal_to do |second_attr|
    @second_attribute = second_attr
    @chain_method = :match_equal_to
  end

  chain :inequal_to do |second_attr|
    @second_attribute = second_attr
    @chain_method = :match_inequal_to
  end

  failure_message_for_should do |actual|
    operation = @chain_method.to_s.sub("match_", "")
    "expected that #{@first_attribute} would be validated that #{@second_attribute} is #{operation} it, but it doesn't"
  end


  def match_greater_than
    set_attrs_equal!
    invalid_when_equal = @model.invalid? && model_has_error?

    set_attrs_less_than!
    invalid_when_less = @model.invalid? && model_has_error?

    set_attrs_greater_than!
    @model.valid?
    valid_when_greater = !model_has_error?

    invalid_when_equal && invalid_when_less && valid_when_greater
  end

  def match_less_than
    set_attrs_equal!
    invalid_when_equal = @model.invalid? && model_has_error?

    set_attrs_greater_than!
    invalid_when_greater = @model.invalid? && model_has_error?

    set_attrs_less_than!
    @model.valid?
    valid_when_less = !model_has_error?

    invalid_when_equal && invalid_when_greater && valid_when_less
  end

  def match_equal_to
    set_attrs_greater_than!
    invalid_when_inequal = @model.invalid? && model_has_error?

    set_attrs_equal!
    @model.valid?
    valid_when_equal = !model_has_error?

    invalid_when_inequal && valid_when_equal
  end

  def match_inequal_to
    set_attrs_equal!
    invalid_when_equal = @model.invalid? && model_has_error?

    set_attrs_greater_than!
    @model.valid?
    valid_when_inequal = !model_has_error?

    invalid_when_equal && valid_when_inequal
  end

  #Evaluated properties
  def first_attribute= (value)
    @model.send("#{@first_attribute}=", value) if @first_attribute.is_a?(String)  || @first_attribute.is_a?(Symbol)
  end

  def second_attribute= (value)
    raise ArgumentError, "second attribute must be string or symbol" unless @second_attribute.is_a?(Symbol) ||  @second_attribute.is_a?(String)

    subject = @model
    attr_name = @second_attribute

    if attr_name.is_a?(String) && attr_name.split(".").size > 1
      chain = attr_name.split(".")
      attr_name = chain.pop
      subject = call_methods_chain(subject, chain)
    end
    subject.send("#{attr_name}=", value)
  end

  def error_message
    return @err_msg if @err_msg

    if @second_attribute.is_a?(String) && @second_attribute.split(".").size > 1
      err_path = "mongoid.errors.models.comparison"
      @err_msg = I18n.t(err_path)
    else
      err_path = "mongoid.errors.models." + @chain_method.to_s.sub("match_", "")
      @err_msg = I18n.t(err_path, f1: @first_attribute, f2: @second_attribute)
    end
    @err_msg
  end

  # Miscelaneous methods
  def set_attrs_equal!
    self.first_attribute= Date.current
    self.second_attribute = Date.current
  end

  def set_attrs_greater_than!
    self.first_attribute = Date.current
    self.second_attribute = Date.yesterday
  end

  def set_attrs_less_than!
    self.first_attribute = Time.zone.now
    self.second_attribute = Time.zone.now + 1.year
  end

  def model_has_error?
    @model.errors[@first_attribute].include?(error_message)
  end

  def call_methods_chain subject, chain
    for i in 0..(chain.size-1)
      subject = subject.send(chain[i])
    end
    subject
  end

end