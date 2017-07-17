$LOAD_PATH.unshift "../lib"
require "static_record"

require "active_record"

ActiveRecord::VERSION::STRING   # => "5.1.2"
ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.integer :gender_key
  end
end

class GenderInfo
  include StaticRecord
  static_record [
    {key: :male,   name: "男"},
    {key: :female, name: "女"},
  ], attr_reader: :name
end

class User < ActiveRecord::Base
  enum gender_key: GenderInfo.keys

  def gender_info
    GenderInfo[gender_key]
  end
end

user = User.create!(gender_key: :male)
user.gender_info.name           # => "男"
