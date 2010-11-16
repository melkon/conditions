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

  def self.set(type, condition)

    @@types[type][condition[:name]] = [] unless @@types[type][condition[:name]]
    @@types[type][condition[:name]].push({:block => condition[:block],
                                           :raise => condition[:raise]})

  end

  def self.unset(type, condition)

    @@types[type][condition[:name]].each_with_index do |saved_condition, index|

      if saved_condition[:block] == condition[:block]

        @@types[type][condition[:name]].delete_at(index)

        # unset only one condition
        return true

      end

    end

  end

  def self.unset_all(type, condition_name)

    @@types[type][condition_name] = Hash.new

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

    # @@todo: implement a notice if condition is dynamically created
    # @@todo: mabye make use of restarts to let the user decide
    Object::const_set(condition_name, Class.new(ConditionDynamic))
  
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