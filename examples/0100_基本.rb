$LOAD_PATH.unshift "../lib"
require "static_record"

class Foo
  include StaticRecord
  static_record [
    {:key => :male,   :name => "男"},
    {:key => :female, :name => "女"},
  ], :attr_reader => :name
end

Foo[:male].name                 # => "男"
Foo[:female].name               # => "女"
