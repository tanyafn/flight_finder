RSpec::Matchers.define :validate_inequality_of do |attr|
  chain :to do |to|
    @to = to
  end

  match do |model|
    raise Exception if @to.nil?
    @val = model.send(attr)
    model.send("#{@to}=", @val)
    @val2 = model.send(@to)
    model.valid?
    model.errors[:base].include?(I18n.t("mongoid.errors.models.inequality", of: attr, to: @to))
  end

  failure_message_for_should do |subject|
    I18n.t("matchers.validate_inequality_of.failure_message", of_attr: attr, val1: @val, to_attr: @to, val2: @val2)
  end
end