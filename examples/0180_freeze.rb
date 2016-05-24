$LOAD_PATH.unshift "../lib"
require "static_record"

class Foo
  include StaticRecord
  static_record [
    {:name => "あ"},
  ], :attr_reader => :name
end

Foo.first.name.upcase! rescue $! # => #<RuntimeError: can't modify frozen String>
