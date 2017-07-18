$LOAD_PATH.unshift "../lib"
require "static_record"

class Foo
  include StaticRecord
  static_record [
    {a: 1},
    {b: 2},
  ], attr_reader_auto: true
end

Foo.first.a                     # => 1
Foo.first.b                     # => nil
