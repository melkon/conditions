# base condition class
require "classes/Condition"

require "conditions_helpers"
require "conditions_exceptions"

def signal condition_name, *params

  value = nil

  condition = generate_condition condition_name, *params

  Handler::get :condition, condition_name do |handler|

    value = case handler[:block].arity
      when 0 then handler[:block].call
      when 1 then handler[:block].call condition
      when 2 then handler[:block].call condition, value
    end

    raise(ConditionHandledError, :value => value, :condition => handler) if handler[:raise]

  end

  value

end

def error condition, *params

  signal condition, *params

  raise ConditionNotHandledError, "condition #{condition} was not handled"

end

def handle *conditions, &block

  conditions = parse_handlers conditions

  conditions.each do |condition|
    Handler::set(:condition, condition.merge!(:raise => true))
  end

  value = begin
    block.call
  rescue ConditionHandledError => ex

    # if condition doesnt belong to this block,
    # continue unwinding the stack
    if !find_handler(ex.condition, conditions) then
      raise ConditionHandledError, :value => ex.value, :condition => ex.condition
    end

    ex.value
  end
  
  conditions.each do |condition|
    Handler::unset(:condition, condition)
  end

  value

end

def bind *conditions, &block

  conditions = parse_handlers conditions

  conditions.each do |condition|
    Handler::set(:condition, condition.merge!(:raise => false))
  end
  
  value = true

  if block_given? then

    value = block.call

    conditions.each do |condition|
      Handler::unset(:condition, condition)
    end

  end

  value

end

def unbind *conditions

  conditions = parse_handlers conditions

  conditions.each do |condition|
    Handler::unset(:condition, condition)
  end

  true
  
end

def restart *restarts, &block

  restarts = parse_handlers restarts

  restarts.each { |restart|  Handler::set(:restart, restart)}

  value = begin
    block.call
  rescue RestartHandledError => ex

    # if restart doesnt belong to this block,
    # continue unwinding the stack
    if !find_handler(ex.restart, restarts) then
      raise RestartHandledError, :value => ex.value, :restart => ex.restart
    end

    ex.value

  end

  restarts.each { |restart| Handler::unset(:restart, restart)}

  value

end

# invoke has to throw a conditon if no restart is found
def invoke restart_name, *params

  Handler::get(:restart, restart_name) do |restart|
    raise RestartHandledError, :value => restart[:block].call(*params), :restart => restart_name
  end

end