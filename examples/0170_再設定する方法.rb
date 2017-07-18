$LOAD_PATH.unshift "../lib"
require "static_record"

class C
  include StaticRecord
  static_record [{key: :a}], attr_reader: :name
end

C.keys                          # => [:a]

# static_record では更新できない
class C
  static_record [{key: :b}], attr_reader: :name
end

C.keys                          # => [:a]

# static_record_list_set を使うこと
C.static_record_list_set [{key: :c}]

C.keys                          # => [:c]
