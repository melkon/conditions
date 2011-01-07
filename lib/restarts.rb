#
# register a possible restart-option
#
# register a possible restart-option
# which can be invoked by an condition handler using #invoke
#
# since its possible to access the method's scope
# you can actually modify the method's behaviour from a handler
# which can be pretty dangerous but also very rewarding.
#
# if no restart was invoked, it returns the value of the block
# otherwise, it returns the value of invoked restart
#
# @param *restarts register restarts 
# @param &block the code to execute normally
#
# @return value of the &block
# @return value of the invoked restart
#
# @raises RestartHandled if the catched restart doesnt belong to this block
#
# @see #parse_handlers for syntax information on *conditions
#
def restart *restarts, &block

  restarts = parse_handlers restarts

  restarts.each { |restart|  Handler::set(:restart, restart)}

  value = begin
    block.call
  rescue RestartHandled => ex

    # if restart doesnt belong to this block,
    # continue unwinding the stack
    if !find_handler(ex.restart, restarts) then
      raise RestartHandled, :value => ex.value, :restart => ex.restart
    end

    ex.value

  end

  restarts.each { |restart| Handler::unset(:restart, restart)}

  value

end

#
# invokes a registered restart
#
# #invoke checks if a restart with restart_name was registered
# and calls it if found.
# 
# @param [String] restart_name the restart which shall be invoked
# @param *params parameters which are needed by the restart
#
# @raises RestartHandled if a invoked restart is called
# @raises RestartNotFoundError if a demanded restart was not found
#
# @see #parse_handlers for syntax information on *conditions
#
def invoke restart_name, *params

  Handler::get(:restart, restart_name) do |restart|
    raise RestartHandled, :value => restart[:block].call(*params), :restart => restart_name
  end

  raise RestartNotFoundError, restart_name

end