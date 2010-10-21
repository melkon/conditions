class Handler

  @@conditions = {}

  def self.get condition_name

    @@conditions[condition_name].reverse_each do |condition|
      yield condition[:block], condition[:raise]
    end

  end

  def self.set condition

    @@conditions[condition[:name]] = [] unless @@conditions[condition[:name]]
    @@conditions[condition[:name]].push({:block => condition[:block],
                                          :raise => condition[:raise]})

  end

  def self.unset conditon

    @@conditions[condition].pop

  end

end

class ConditionError < StandardError; end
class ConditionNotHandledError < StandardError; end

class ConditionHandledError < StandardError

  attr_accessor :value

  def initialize value

    @value = value

  end

end

def signal condition_name, *params

  Handler::get condition_name do |block, raise|

    value = block.call
    raise ConditionHandledError, value if raise

  end

  value

end

def error condition, *params

  signal condition, *params

  raise ConditionNotHandledError, *params

end


def handle *conditions, &block

  begin
    
    # register the conditions
    conditions.each do |handler|

      condition = handler.shift
      Handler::set({:name => condition.fetch(0),
                    :block => condition.fetch(1),
                    :raise => true})
      
    end

    value = block.call

  rescue ConditionHandledError => ex

    # return the handler's value
    value = ex.value

  end

  value

end