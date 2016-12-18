$LOAD_PATH.unshift "../lib"
require "static_record"

class C
  def self.x
    @x ||= 1
  end
end

class C2
  include StaticRecord
  static_record [
    {:model => C},
  ], :attr_reader_auto => true

  def x
    @x ||= 1
  end
end

C2.first.x                      # => 1
C2.first.model.x                # => 
# ~> -:6:in `x': can't modify frozen #<Class:C> (RuntimeError)
# ~> 	from -:22:in `<main>'
