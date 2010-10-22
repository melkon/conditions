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

=begin

#restart :restart => proc {},
#         :another_restart => proc {} do
#
#  error :condition
#
#end

end

bind :condition => funciton
unbind :condition => function

=end