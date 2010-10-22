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

class ConditionError < StandardError; end
class ConditionNotHandledError < StandardError; end
class NoConditionHandlerError < StandardError; end

class ConditionHandledError < StandardError

  attr_accessor :value, :condition

  def initialize info

    @value = info[:value]
    @condition = info[:condition]

  end

end

def signal condition_name, *params

  value = nil

  Handler::get condition_name do |condition|

    value = condition[:block].call

    raise(ConditionHandledError, :value => value, :condition => condition) if condition[:raise]

  end

  value

end

def error condition, *params

  signal condition, *params

  raise ConditionNotHandledError, *params

end

def parse_conditions conditions
  
  without_proc = []
  parsed = []

  conditions.each do |condition|

    if condition.is_a? Hash

      condition.each do |condition_name, condition_proc|

        without_proc.each do |condition_name|
          parsed.push :name => condition_name, :block => condition_proc
        end

        parsed.push :name => condition_name, :block => condition_proc

      end

      without_proc.clear

    else

      without_proc.push condition
      
    end

  end

  parsed

end


def handle *conditions, &block

  conditions = parse_conditions conditions

  conditions.each do |condition|
    Handler::set condition.merge! :raise => true
  end

  value = begin
    block.call
  rescue ConditionHandledError => ex
    removed_condition = ex.condition
    ex.value
  end

  conditions.each do |condition|
    Handler::unset condition unless condition == removed_condition
  end

  value

end