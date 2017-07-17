$LOAD_PATH.unshift "../lib"
require "static_record"

class C
  include StaticRecord
  static_record [
    {:key => :a, :x => 1},
  ]
end

C[:a][:x] # => 1
