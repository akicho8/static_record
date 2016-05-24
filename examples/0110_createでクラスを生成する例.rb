$LOAD_PATH.unshift "../lib"
require "static_record"

foo = StaticRecord.create [
  {:code => 1, :key => :a, :name => "A"},
  {:code => 2, :key => :b, :name => "B"},
  {:code => 3, :key => :c, :name => "C"},
], :attr_reader => :name

foo[2].name                      # => "B"
foo[:b].name                     # => "B"
foo.collect(&:to_s)              # => ["A", "B", "C"]
