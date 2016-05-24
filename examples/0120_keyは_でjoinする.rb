$LOAD_PATH.unshift "../lib"
require "static_record"

foo = StaticRecord.create([{:key => [:id, :desc]}])
foo.keys                        # => [:id_desc]
