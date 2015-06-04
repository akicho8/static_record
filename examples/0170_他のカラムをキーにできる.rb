# -*- coding: utf-8 -*-
$LOAD_PATH.unshift "../lib"
require "static_record"

class Foo
  include StaticRecord
  static_record [
    {:key => "↑", :name => "上"},
  ], :attr_reader => :name, :support_key => [:name]
end

Foo["↑"].name                  # => "上"
Foo["上"].name                  # => "上"
