$LOAD_PATH.unshift "../lib"
require "static_record"

class Foo
  include StaticRecord
  static_record [
    {:key => "↑", :name => "上"},
  ], :attr_reader => :name
end

Foo["↑"].name                      # => "上"
