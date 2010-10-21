require "./conditions"

# #########
#  usage
# #########

p (handle :condition => lambda {

  "hallo"

} do

  error :condition, "condition error" if 0 == 1

  "welt"

end)




=begin

bind :condition => lambda {|block|


} do


end

bind :condition => funciton
unbind :condition => function

=end