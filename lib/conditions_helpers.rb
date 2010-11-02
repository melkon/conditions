class Handler

  @@conditions = {}

  def self.get condition_name

    return nil if (!@@conditions.has_key?(condition_name) or @@conditions[condition_name].empty?)

    @@conditions[condition_name].reverse_each do |condition|

      condition[:name] = condition_name
      self.unset condition

      yield condition

    end

  end

  def self.set condition

    @@conditions[condition[:name]] = [] unless @@conditions[condition[:name]]
    @@conditions[condition[:name]].push({:block => condition[:block],
                                           :raise => condition[:raise]})

  end

  def self.unset condition

    @@conditions[condition[:name]].each_with_index do |saved_condition, index|

      if saved_condition[:block] == condition[:block]

        @@conditions[condition[:name]].delete_at index

        # unset only one condition
        return true

      end

    end

  end

  def self.unset_all condition_name

    @@condition[condition_name] = Hash.new

  end

end

class Restart

  @@restarts = {}

  def self.get restart_name

    return nil if (!@@restarts.has_key?(restart_name) or @@restarts[restart_name].empty?)

    @@restarts[restart_name].reverse_each do |restart|

      restart[:name] = restart_name
      self.unset restart

      yield restart

    end

  end

  def self.set restart

    @@restarts[restart[:name]] = [] unless @@restarts[restart[:name]]
    @@restarts[restart[:name]].push({:block => restart[:block]})

  end

  def self.unset restart

    @@restarts[restart[:name]].each_with_index do |saved_restart, index|

      if saved_restart[:block] == restart[:block]

        @@restarts[restart[:name]].delete_at index

        # unset only one restart
        return true

      end

    end

  end

  def self.unset_all restart_name

    @@restart[restart_name] = Hash.new

  end

end


def parse_handlers handlers

  without_proc = []
  parsed = []

  handlers.each do |handler|

    if handler.is_a? Hash

      handler.each do |handler_name, handler_proc|

        without_proc.each do |handler_name|
          parsed.push :name => handler_name, :block => handler_proc
        end

        parsed.push :name => handler_name, :block => handler_proc

      end

      without_proc.clear

    else

      without_proc.push handler

    end

  end

  parsed

end

def generate_condition condition_name, *params

  if !Kernel.const_defined? condition_name then

    # @@todo: implement a notice if condition is dynamically created
    # @@todo: mabye make use of restarts to let the user decide
    Object::const_set(condition_name, Class.new(Condition) do

      def initialize *params

        @dynamic = true

      end
      
    end)
  
  end
  
  Object::const_get(condition_name).new(*params)

end