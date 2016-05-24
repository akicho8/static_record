$LOAD_PATH.unshift "../lib"
require "static_record"

StaticRecord.create([{:key => :a, :x => 1, :y => 2}])[:a][:x] # => 1
