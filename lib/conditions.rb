# main api
require "conditions/signals"
require "conditions/handles"
require "conditions/restarts"

# base condition classes
require "conditions/definitions/defaults"

# helper functions and exception definitions
require "conditions/lib/helpers"
require "conditions/lib/exceptions"

# remove this and the puppy will cry
class Object
  include Conditions
end