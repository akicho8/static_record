$LOAD_PATH.unshift "../lib"
require "static_record"

class Direction
  include StaticRecord
  static_record [
    {:key => :left,  :name => "左", :vector => [-1,  0]},
    {:key => :right, :name => "右", :vector => [ 1,  0]},
  ], :attr_reader_auto => true

  def long_name
    "#{name}方向"
  end
end

Direction.collect(&:name)       # => ["左", "右"]
Direction.keys                  # => [:left, :right]

Direction[:right].key           # => :right
Direction[:right].code          # => 1
Direction[:right].vector        # => [1, 0]
Direction[:right].long_name     # => "右方向"

Direction[1].key                # => :right

Direction[:up]                  # => nil
Direction.fetch(:up) rescue $!  # => #<KeyError: Direction.fetch(:up) では何にもマッチしません。
