
class ConditionNotHandledError < StandardError; end
class ConditionHandledError < StandardError

  attr_accessor :value, :condition

  def initialize info

    @value = info[:value]
    @condition = info[:condition]

  end

end