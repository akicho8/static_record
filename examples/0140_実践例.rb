$LOAD_PATH.unshift "../lib"
require "static_record"

class Direction
  include StaticRecord

  static_record [
    {:key => :up,    :name => "上", :arrow => "↑", :vector => [ 0, -1]},
    {:key => :down,  :name => "下", :arrow => "↓", :vector => [ 0,  1]},
    {:key => :left,  :name => "左", :arrow => "←", :vector => [-1,  0]},
    {:key => :right, :name => "右", :arrow => "→", :vector => [ 1,  0]},
  ], :attr_reader => [:name, :arrow, :vector]

  def char
    key[0]
  end
end

Direction[:right].key           # => :right
Direction[:right].code          # => 3
Direction[3].key                # => :right

Direction[4]                    # => nil
Direction[nil]                  # => nil

Direction[:right].char          # => "r"

Direction.first.key             # => :up
Direction.to_a.last.key         # => :right

Direction.collect(&:name)       # => ["上", "下", "左", "右"]
