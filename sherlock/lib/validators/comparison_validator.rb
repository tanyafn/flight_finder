class ComparisonValidator < ActiveModel::EachValidator
  attr_reader :operator

  def check_validity!
    raise ArgumentError, "options can not be blank" if options.blank?
    options.each do |key, val|
      raise ArgumentError, "#{key} must be a string, a symbol or a proc" unless val.is_a?(Symbol) || val.is_a?(String) || val.is_a?(Proc)
      raise ArgumentError, "#{key} value must be a non-empty" if val.blank?
    end
  end

  def validate_each(record, attribute, value)
    second_value = eval_value(record, options[:with])
    record.errors[attribute] << error_message(attribute, options[:with]) unless value.send(operator, second_value)
  end

  def error_message(first_attr, second_attr)
    err_path = "mongoid.errors.models.comparison"
    err_msg = I18n.t(err_path)

    if (second_attr.is_a?(String) && !is_methods_chain?(second_attr)) || second_attr.is_a?(Symbol)
      err_path = "mongoid.errors.models." + self.class.name.chomp("Validator").tableize.singularize
      err_msg = I18n.t(err_path, f1: first_attr, f2: second_attr)
    end
    err_msg
  end

  private

  def methods_chain? val
    val.split(".") > 1
  end

  def eval_value(record, attr_to_eval)
    return attr_to_eval.call(record) if attr_to_eval.is_a?(Proc)
    return call_methods_chain(record, attr_to_eval.split(".")) if attr_to_eval.is_a?(String)
    return record.send(attr_to_eval) if attr_to_eval.is_a?(Symbol)

    rescue
      raise ArgumentError, "Impossible to evaluate #{attr_to_eval.to_s}"
  end

   def call_methods_chain target, chain
    for i in 0..(chain.size-1)
      target = target.send(chain[i])
    end
    target
  end
end
