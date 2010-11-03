require "conditions"

# #########
#  usage
# #########

# returns "foo"

handle :Condition => lambda { signal :Another_condition } do

  handle :Condition => lambda {

    error :Condition

    "foo"

  } do

    error :Condition

    "bar"

  end
  
end

# returns "bar"
handle :Condition, {:Another => lambda { |condition|

  "foo"

}}, :Yet_another, {:Last => lambda { |condition|

    p condition.get 0
    p condition.trace

  "bar"

}} do

  error :Last, "muff"

  "baz"

end

func = lambda { "foo" }

bind :Condition => func

# "foo"
p(signal :Condition)

unbind :Condition => func

# nil
p(signal :Condition)

def hallo x

  restart :Restart => proc { x = hallo 0 },
           :Test => proc { x = hallo 0 - x } do

    if x < 0 then
      error :Condition
    else
      x = x + 1
    end

  end

  x

end

bind :Condition => lambda { invoke :Test } do

  p hallo -1

end