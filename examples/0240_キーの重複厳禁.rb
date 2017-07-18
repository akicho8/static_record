$LOAD_PATH.unshift "../lib"
require "static_record"

class Foo
  include StaticRecord
  static_record [{key: :a}, {key: :a},] rescue $! # => #<ArgumentError: Foo#key の :a が重複しています
end

class Bar
  include StaticRecord
  static_record [{code: 0}, {code: 0},] rescue $! # => #<ArgumentError: Bar#code の 0 が重複しています
end
