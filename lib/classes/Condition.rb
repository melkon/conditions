class Condition

  attr_reader :dynamic, :trace, :message, :restarts

  def initialize message = nil

    @message = message
    
    @trace = Kernel.caller
    @dynamic = false
    @restarts = Handler::get_restarts

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

class DynamicConditionCreation  < Condition ; end
class ConditionNotDefined       < Condition ; end
class NoDynamicConditionAllowed < Condition ; end