module Conditions::Utils

  class Handler

    @@types = {:condition => {},
                :restart   => {}}

    #
    # yields every registered condition for given type
    #
    # opts:
    #   :reverse => true|false [default: true] LIFO or FIFO of yielded handlers
    #
    # @param [String, Symbol] supported types: :condition, :restart
    # @param [String, Symbol] name of the condition
    # @param [Hash] opts current available: :reverse => true
    #
    def self.get(type, condition_name, opts = {})

      condition_name = Utils::normalize(condition_name)

      if (!@@types[type].has_key?(condition_name)) or (@@types[type][condition_name].empty?)
        return nil
      end

      opts[:reserve] = true unless opts[:reserve] === false

      if opts[:reserve] === true
        direction = :reverse_each
      else
        direction = :each
      end

      @@types[type][condition_name].send(direction) do |condition|

        condition[:name] = condition_name

        yield condition

      end

    end

    def self.get_restarts()
      return @@types[:restarts];
    end

    def self.get_handlers()
      return @@types[:condition];
    end

    def self.set(type, condition)

      condition[:name] = Utils::normalize(condition[:name])

      @@types[type][condition[:name]] = [] unless @@types[type][condition[:name]]
      @@types[type][condition[:name]].push({:block => condition[:block],
                                            :raise => condition[:raise]})

    end

    def self.unset(type, condition)

      condition[:name] = Utils::normalize(condition[:name])

      @@types[type][condition[:name]].each_with_index do |saved_condition, index|

        if saved_condition[:block] == condition[:block]

          # completely delete the restart-entry if no block is given anymore
          if 2 >@@types[type][condition[:name]].size then
            @@types[type].delete(condition[:name])
          else
            @@types[type][condition[:name]].delete_at(index)
          end

          # unset only one condition
          return true

        end

      end

    end

  end

  #
  # parses magically the correct handlers / restarts
  #
  # #parse_handlers takes a hash as an argument and tries to identify
  # the handlers / restarts and their callbacks. the syntax is the same for both.
  #
  # the simpliest is:
  #
  # :HandlerName => callback[, ...]
  #
  # class names are also supported:
  #
  # HandlerNAme => callback[, ...]
  #
  # class names as well as symbol will be casted to strings internally.
  #
  # currently, the callback has to be a lambda or
  # a proc function to work within the condition system.
  #
  # it's also possible to define multiple handlers / restarts with the same callback:
  #
  # :HandlerName1, :HandlerName2, {:HandlerName3 => callback}[, ...]
  #
  # now let's mix everything together:
  #
  # :HandlerName => callback, HandlerName1, {:HandlerName2 => callback}, :HandlerName3 => callback
  #
  # why does this work?
  #
  # it's a lot of magic with hashes, since the #handle and #restart functions are using the * operator.
  # this way, the parameters are wrapped in a Hash and can be magically transformed.
  #
  # @param [Hash] handlers a multidimensional Hash
  #
  # @return [Hash] a structured hash {{:name => :HandlerName, :block => callback}[, ...}}
  #
  def self.parse_handlers(handlers)

    without_proc = []
    parsed = []

    handlers.each do |handler|

      if handler.is_a? Hash

        handler.each do |handler_name, handler_proc|

          without_proc.each do |handler_name|
            parsed.push(:name => handler_name, :block => handler_proc)
          end

          parsed.push(:name => handler_name, :block => handler_proc)

        end

        without_proc.clear

      else

        without_proc.push(handler)

      end

    end

    parsed

  end

  #
  # creates a condition object
  #
  # creates a condition object of given conditon_name symbol or string-class
  # if the requested condition_name is not a existing class,
  # #generate_condition registers a restart offering to dynamically create class.
  # currently, the new class will be created in the module Conditions.
  #
  # this condition class inherits the class ConditionDynamic.
  #
  # @param [String, Symbol] condition_name the condition class' name to instance. it must start with an upper case letter!
  # @param *params parameters forwarded to the condition class' constructor
  #
  # @return [Condition] object of the demanded condition class
  #
  # @error :ConditionNotDefined if requested condition class does not exist
  #
  # @restart :Define creates a dynamic condition named like condition_name
  #
  def self.generate_condition(condition_name, *params)

    if not condition_name.kind_of?(Class)

      if !Conditions.const_defined? condition_name then
        restart :WriteToFile => lambda { p "will be implemented anytime soon" },
                 :Define      => lambda { Conditions::const_set(condition_name, Class.new(ConditionDynamic))
                                           notice :DynamicConditionCreation, "#{condition_name} dynamically created" } do

            error :ConditionNotDefined, condition_name
        end
      end

      condition_name = Conditions::const_get(condition_name)

    end
    
    condition_name.new(*params)

  end

  #
  # finds a handler in the given hash
  #
  # @param [String, Symbol] the handler / restart to find
  # @param [Hash] a hash of handlers / restarts: {{:name => :Handlername}[, ...]}
  #
  # @return [Boolean] true if found
  # @return [Boolean] false if not
  #
  def self.find_handler(name, handlers)

    name = Utils::normalize(name)

    handlers.each do |handler|

      if name == handler[:name]
        return true
      end

    end

    false

  end

  def self.normalize(name)
    return name.to_s
  end

end