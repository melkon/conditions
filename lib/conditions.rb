# base condition class
require "classes/Condition"

require "conditions_helpers"
require "conditions_exceptions"

#
# calls the registered handler for given condition
#
# if the registered handler is established using #handle,
# the call to #signal will not return and raise an exception instead.
#
# if it's established using bind, #signal will return normally with
# the handler's returned value.
#
# @param [Symbol] conditon_name the condition to signal
# @param *params additional information wich will be directly passed
#                to the condition's constructor
#
# @return value the return value of the called handler.
#
# @raises ConditionHandledError if a handler is established with #handle
#
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

#
# errors a condition
#
# it's build on top of #signal but will raise an ConditionNotHandledError
# if #signal returns normally. This ensures that a condition errored using
# #error has to be handled by a condition handler with an non-local exit
# as it's done by using #handle.
#
# @param [Symbol] condition condition's name
# @param *params additional information wich will be directly passed
#                to the condition's constructor
#
# @raises ConditionNotHandledError if the condition was not handled
#
def error condition, *params

  signal condition, *params

  raise ConditionNotHandledError, "condition #{condition} was not handled"

end

#
# notices a condition
#
# it's build on top of #signal and will print the given message
# it can be suppressed by invoking the restart :Suppress.
#
# since notice is calling #signal,
# the given condition can also be handled
#
# if no handler is bound to given condition, #notice returns normally.
#
# @param [Symbol] condition condition's name
# @param [String] message
#
# @return nil or bound handler's returned value
#
# @signal :NoticeSignaled if #notice got called.
#
# @restart :Suppress message will not be printed
#
def notice condition, message
  
  restart :Suppress => lambda { nil } do
    signal :NoticeSignaled, condition
    print "Notice: #{message}"
  end

  signal condition

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
    if !find_handler(ex.condition[:name], conditions) then
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

  raise RestartNotFoundError, restart_name

end