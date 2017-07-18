$LOAD_PATH.unshift "../lib"
require "static_record"

class Foo
  include StaticRecord
  static_record [
    {key: "true",  name: "有効"},
    {key: "false", name: "無効"},
  ], attr_reader: :name
end

flag = true

Foo[flag.to_s].name             # => "有効"
