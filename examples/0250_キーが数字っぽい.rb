$LOAD_PATH.unshift "../lib"
require "static_record"

class Foo
  include StaticRecord
  static_record [
    {key: '01', name: "右"},
    {key: '02', name: "左"},
  ], attr_reader: :name
end

Foo["01"] # => #<Foo:0x007fd7a1997318 @attributes={:key=>:"01", :name=>"右", :code=>0}>
Foo["02"] # => #<Foo:0x007fd7a1997138 @attributes={:key=>:"02", :name=>"左", :code=>1}>
