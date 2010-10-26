require "conditions"

# #########
#  usage
# #########

# returns "foo"

handle :condition => lambda { signal :another_condition } do

  handle :condition => lambda {

    error :condition

    "foo"

  } do

    error :condition

    "bar"

  end
  
end

# returns "bar"
handle :condition, {:another => lambda {

  "foo"

}}, :yet_another, {:last => lambda {

  "bar"

}} do

  error :yet_another

  "baz"

end

func = lambda { "foo" }

bind :condition => func

# "foo"
p(signal :condition)

unbind :condition => func

# nil
p(signal :condition)

def hallo x

  restart :restart => proc { x = hallo 0 },
          :test => proc { x = hallo 0 - x } do

    if x < 0 then
      error :condition
    else
      x = x + 1
    end

  end

  x

end

bind :condition => lambda { invoke :test } do

  p hallo -1

end