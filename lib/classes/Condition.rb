class Condition

  attr_accessor :dynamic, :trace, :message

  def initialize message = ""

    @message = message
    
    @trace = Kernel.caller
    @dynamic = false

  end

end

class ConditionDynamic < Condition
  
  attr_accessor :params

  def initialize *params

    super params

    @params = params
    @dynamic = true
    
  end

  def get key
    @params[key]
  end

end