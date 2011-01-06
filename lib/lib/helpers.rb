class Handler

  @@types = {:condition => {},
             :restart   => {}}

  def self.get(type, condition_name)

    if (!@@types[type].has_key?(condition_name)) or (@@types[type][condition_name].empty?)
      return nil
    end

    @@types[type][condition_name].reverse_each do |condition|

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

    @@types[type][condition[:name]] = [] unless @@types[type][condition[:name]]
    @@types[type][condition[:name]].push({:block => condition[:block],
                                          :raise => condition[:raise]})

  end

  def self.unset(type, condition)

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

def parse_handlers(handlers)

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

def generate_condition(condition_name, *params)

  if !Kernel.const_defined? condition_name then
    restart :WriteToFile => lambda { p "will be implemented anytime soon" },
            :Define      => lambda { Object::const_set(condition_name, Class.new(ConditionDynamic))
                                     notice :DynamicConditionCreation, "#{condition_name} dynamically created" } do

        error :ConditionNotDefined, condition_name
    end
  end
  
  Object::const_get(condition_name).new(*params)

end

def find_handler(name, handlers)

  handlers.each do |handler|

    if name == handler[:name]
      return true
    end
    
  end
  
  false

end