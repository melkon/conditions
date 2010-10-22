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

#restart :restart => proc {},
#         :another_restart => proc {} do
#
#  error :condition
#
#end


=begin

bind :condition => lambda {|block|


} do


end

bind :condition => funciton
unbind :condition => function

=end