$LOAD_PATH.unshift "../lib"
require "static_record"

class Foo
  include StaticRecord
  static_record [
    {:name => "alice"},
    {:name => "bob"},
  ], :attr_reader_auto => true
end

require "active_model"

class Foo
  include ActiveModel::Validations
  validates :name, length: { maximum: 3 }
end

Foo.collect(&:valid?)           # => [false, true]

foo = Foo.first
foo.valid?                     # => false
foo.errors.full_messages       # => ["Name is too long (maximum is 3 characters)"]
