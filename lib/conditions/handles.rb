module Conditions

  #
  # handles a signaled condition
  #
  # handles a condition signaled by #signal or any other signaling method
  # by registering handlers for given conditions.
  #
  # if a handler matches a condition, it will be executed and after that,
  # the stack will be unwound to the point where the latest #handle registered
  # a handler for given condition returning the value of the executed handler.
  #
  # @param *conditions conditions which shall be catched by #handle,
  # @param &block block which will be executed normally if no condition will be signaled
  #
  # @return return value of &block
  # @return if a condition is catched, the return value of the registered handler
  #
  # @raises ConditionHandled if the catched condition doesnt belong to current block
  #
  # @see #parse_handlers for syntax information on *conditions
  #
  def handle *conditions, &block

    conditions = Utils::parse_handlers conditions

    conditions.each do |condition|
      Utils::Handler::set(:condition, condition.merge!(:raise => true))
    end

    value = begin
      block.call
    rescue Exception::ConditionHandled => ex

      # if condition doesnt belong to this block,
      # continue unwinding the stack
      if !Utils::find_handler(ex.condition[:name], conditions) then
        raise Exception::ConditionHandled, :value => ex.value, :condition => ex.condition
      end

      ex.value

    end

    conditions.each do |condition|
      Utils::Handler::unset(:condition, condition)
    end

    value

  end

  #
  # binds a handler to a condition
  #
  # #bind works similiar to #handle but instead of unwinding the stack,
  # #bind returns the value of the last called handler.
  #
  # caveat:
  #
  # *if* there's a condition bound by #handle in the upper callstack
  # *and* the same condition is bound by #bind inside of this #handle,
  # the system will unwind the stack to #handle - but the condition's handler
  # bound by #bind will be executed and properly unregistered.
  #
  # @param *conditions conditions which shall be bound by #bind,
  # @param &block block which will be executed normally if no condition will be signaled
  #
  # @return return value of &block
  # @return if a condition is signaled and bound by #bind, it returns value of the last registered handler
  #
  # @see #parse_handlers for syntax information on *conditions
  #
  def bind *conditions, &block

    conditions = Utils::parse_handlers conditions

    conditions.each do |condition|
      Utils::Handler::set(:condition, condition.merge!(:raise => false))
    end

    value = true
    if block_given? then

      value = begin

        block.call

        conditions.each do |condition|
          Utils::Handler::unset(:condition, condition)
        end

      # it is possible that a Condition has a handler registered by #handle
      # and therefore will unwind the stack. but if a handler bound by #bind
      # and #bind is used with a block, the bound handler will not be unregistered.
      # therefore, catch the exception intended for #handle
      # unregister the handler registered by #bind
      # and rethrow the exception again to reach the proper #handle
      rescue Exception::ConditionHandled => ex

        conditions.each do |condition|
          Utils::Handler::unset(:condition, condition)
        end

        raise Exception::ConditionHandled, :value => ex.value, :condition => ex.condition

      end

    end

    value

  end

  #
  # unregisters a bound condition
  #
  # if bind is used without a block,
  # #unbind is used to unregister the condition's handler
  #
  # @param *conditions conditions which shall be unregistered by #unbind,
  #
  # @return [Boolean] true
  #
  # @see #parse_handlers for syntax information on *conditions
  #
  def unbind *conditions

    conditions = Utils::parse_handlers conditions

    conditions.each do |condition|
      Exception::Handler::unset(:condition, condition)
    end

    true

  end

end
