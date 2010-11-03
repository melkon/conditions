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

class NoHandlerFound < Condition

  attr_accessor :type, :name

  def initialize type, name

    # prevent endless loop (have to think about this again)
    if name == :NoHandlerFound then
      raise Exception, "no condition handler found, aborting."
    end

    @type = type
    @name = name
  end

end