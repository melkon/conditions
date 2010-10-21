require "./conditions"

# #########
#  usage
# #########

value = handle :condition => lambda {

  "foo"

} do

  error :condition

  "bar"

end

p value

value = handle :condition, {:another => lambda {

  "foo"

}}, :yet_another, {:last => lambda {

  "bar"

}} do

  error :yet_another

  "baz"

end

p value



=begin

bind :condition => lambda {|block|


} do


end

bind :condition => funciton
unbind :condition => function

=end