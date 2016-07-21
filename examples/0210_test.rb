$LOAD_PATH.unshift "../lib"
require "static_record"
$LOAD_PATH.unshift "../../../src/tree_support/lib"
require "tree_support"

module M
  def to_h
    attributes
  end
end

class Foo
  include StaticRecord
  include M
  static_record [
    {:key => :a, :parent_key => nil},
    {:key => :b, :parent_key => :a },
  ], :attr_reader_auto => true

  include Enumerable

  def each(&block)
    children.each(&block)
  end

  def parent
    self.class[parent_key]
  end

  def children
    self.class.find_all {|e| e.parent == self }
  end
end

Foo.to_a.collect(&:name)        # => ["A", "B"]
Foo.values.collect(&:name)      # => ["A", "B"]
puts Foo.first.attributes       # => nil
puts Foo.first.to_h             # => 
# ~> -:23:in `each': wrong element type Foo (expected array) (TypeError)
# ~> 	from -:23:in `each'
# ~> 	from -:38:in `to_h'
# ~> 	from -:38:in `<main>'
# >> {:key=>:a, :parent_key=>nil, :code=>0}
