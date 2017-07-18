$LOAD_PATH.unshift "../lib"
require "static_record"

class C
  include StaticRecord
  static_record [
    {key: [:a, :b]},
  ]
end

C.keys                          # => [:a_b]
