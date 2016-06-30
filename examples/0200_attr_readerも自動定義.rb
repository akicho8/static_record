$LOAD_PATH.unshift "../lib"
require "static_record"

class Foo
  include StaticRecord
  static_record [
    {:a => 1},
    {:b => 2},
  ], :auto_attr_reader => true
end

Foo.first.a                     # => 1
Foo.first.b                     # => nil
