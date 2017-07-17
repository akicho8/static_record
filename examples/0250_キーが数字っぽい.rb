$LOAD_PATH.unshift "../lib"
require "static_record"

class Foo
  include StaticRecord
  static_record [
    {:key => '01', :name => "男"},
    {:key => '02', :name => "女"},
  ], :attr_reader => :name
end

Foo["01"] # => #<Foo:0x007fda3e8c6fc0 @attributes={:key=>:"01", :name=>"男", :code=>0}>
Foo["02"] # => #<Foo:0x007fda3e8c6e30 @attributes={:key=>:"02", :name=>"女", :code=>1}>

Foo[:male].name                 # => 
Foo[:female].name               # => 
# ~> -:15:in `<main>': undefined method `name' for nil:NilClass (NoMethodError)
