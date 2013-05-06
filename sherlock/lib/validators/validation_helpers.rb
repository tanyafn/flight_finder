module ValidationHelpers
  extend ActiveSupport::Concern

  module ClassMethods
=begin
    def validates_inequality_of attr, opts={}
       validates attr, inequal_to: opts[:to]
    end

    def validates_equality_of attr, opts={}
      validates attr, equal_to: opts[:to]
    end
=end
  end
end