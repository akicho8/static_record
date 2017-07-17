$LOAD_PATH.unshift "../lib"
require "static_record"

# class Foo
#   include StaticRecord
#   static_record [
#     {:key => :male,   :name => "男"},
#     {:key => :female, :name => "女"},
#   ], :attr_reader => :name
# end
# 
# Foo[:male]   # => #<Foo:0x007ff8832241f0 @attributes={:key=>:male, :name=>"男", :code=>0}>
# Foo[:female] # => #<Foo:0x007ff883224100 @attributes={:key=>:female, :name=>"女", :code=>1}>
# 
# Foo[:male].name                 # => "男"
# Foo[:female].name               # => "女"

# GENDER       = {male: "男", female: "女", }
# GENDER_COLOR = {male: "青", female: "赤" }
# GENDER_USERS = {male: proc{ User.where(:gender_key => :male) } }
# 
# GENDER[:male]                   # => "男"
# GENDER[:female]                 # => "女"
# 
# GENDER.to_a[0].last                  # => "男"
# 
# GENDER[:male].users             # =>
# User.where(:gender_key => :male)

class GenderInfo
  include StaticRecord
  static_record [
    {:key => :male,   :name => "男", :color => "青"},
    {:key => :female, :name => "女", :color => "赤"},
  ], :attr_reader_auto => true

  def long_name
    "<#{color}>#{name}性</#{color}>"
  end

  def color
    super + "色"
  end
end

GenderInfo[:male].name           # => "男"
GenderInfo[:male].long_name      # => "<青色>男性</青色>"

GenderInfo.collect(&:name)      # => ["男", "女"]
GenderInfo.inject({}) {|a, e| a.merge(e.key => e.name) } # => {:male=>"男", :female=>"女"}
