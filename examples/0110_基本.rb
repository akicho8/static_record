$LOAD_PATH.unshift "../lib"
require "static_record"

class Foo
  include StaticRecord
  static_record [
    {:key => :male,   :name => "男"},
    {:key => :female, :name => "女"},
  ], :attr_reader => :name
end

Foo[:male]   # => #<Foo:0x007ff8832241f0 @attributes={:key=>:male, :name=>"男", :code=>0}>
Foo[:female] # => #<Foo:0x007ff883224100 @attributes={:key=>:female, :name=>"女", :code=>1}>

Foo[:male].name                 # => "男"
Foo[:female].name               # => "女"
