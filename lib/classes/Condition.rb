class Condition

  attr_reader :dynamic, :trace, :message

  def initialize message = nil

    @message = message
    
    @trace = Kernel.caller
    @dynamic = false

  end

end

class ConditionDynamic < Condition
  
  def initialize *params

    super params

    @params = params
    @dynamic = true
    
  end

  def get key
    @params[key]
  end

end