module Conditions ; end

# base condition classes
require "conditions/definitions/defaults"

# helper functions and exception definitions
require "conditions/lib/helpers"
require "conditions/lib/exceptions"

# main api
require "conditions/signals"
require "conditions/handles"
require "conditions/restarts"

class Object
  include Conditions
end