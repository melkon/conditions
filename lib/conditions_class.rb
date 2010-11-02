class Condition

  attr_accessor :dynamic

  def initialize *params

    @dynamic = false

  end

end

class ConditionNotFound < Condition; end

def create condition_name, *params

    Object::const_set(condition_name, Class.new(Condition) do

      def initialize *params

        super
        @dynamic = true
        
      end
      
    end)

end