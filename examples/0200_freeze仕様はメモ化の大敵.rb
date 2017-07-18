# freeze してしまうとこれらのメモ化ができなくなる

$LOAD_PATH.unshift "../lib"
require "static_record"

class C
  def self.x
    @x ||= "OK"
  end
end

class C2
  include StaticRecord
  static_record [
    {model: C},
  ], attr_reader_auto: true

  def x
    @x ||= "OK"
  end
end

C2.first.x                      # => "OK"
C2.first.model.x                # => "OK"
