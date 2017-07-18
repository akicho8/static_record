$LOAD_PATH.unshift "../lib"
require "static_record"

model = Class.new do
  include StaticRecord
  static_record [
    {foo: 1},
    {foo: 2},
  ], attr_reader_auto: true
end

model.first.name                # => nil
