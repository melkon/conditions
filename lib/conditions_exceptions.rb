
class ConditionNotHandledError < StandardError ; end
class ConditionHandledError < StandardError

  attr_reader :value, :condition

  def initialize info

    super info[:value]
    
    @value = info[:value]
    @condition = info[:condition]

  end

end

class RestartHandledError < StandardError

  attr_reader :value, :restart

  def initialize info

    super info[:value]

    @value = info[:value]
    @restart = info[:restart]

  end

end