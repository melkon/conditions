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