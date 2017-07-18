$LOAD_PATH.unshift "../lib"
require "static_record"

class Foo
  include StaticRecord
  static_record [
    {a: 10},
  ], attr_reader: :a

  def a
    super * 2
  end

  def name
    "(#{super})"
  end
end

Foo.first.a                     # => 20
Foo.first.name                  # => "(Key0)"
