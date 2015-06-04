# -*- coding: utf-8 -*-
require 'spec_helper'

class FooInfo1
  include StaticRecord
  list = [
    {:code => 10, :key => :a, :name => "A"},
    {:code => 20, :key => :b, :name => "B"},
  ]
  static_record(list, :attr_reader => :name)
end

class FooInfo2
  include StaticRecord
  list = [
    {:name => "A"},
    {:name => "B"},
  ]
  static_record(list, :attr_reader => :name)
end

class FooInfo3
  include StaticRecord
  list = [
    {:code => 10},
    {:code => 20},
  ]
  static_record(list)
end

FooInfo4 = StaticRecord.create [
  {:key => :a},
  {:key => :b},
]

FooInfo5 = StaticRecord.define do
  [
    {:key => :a},
    {:key => :b},
  ]
end

RSpec.describe StaticRecord do
  it "コードやキーは自分で定義する場合" do
    assert_equal "A", FooInfo1[10].name
  end

  it "コードもキーも自動で振る場合" do
    assert_equal "A", FooInfo2[0].name
  end

  it "キーの配列だけ欲しい" do
    assert_equal [:_key0, :_key1], FooInfo2.keys
  end

  it "値の配列" do
    assert_equal FooInfo2.each.to_a, FooInfo2.values
  end

  it "name メソッドは自動的に定義" do
    assert_equal true, FooInfo3.instance_methods.include?(:name)
  end

  it "create で無名クラスを返す" do
    assert_equal :a, FooInfo4.first.key
  end

  it "define で無名クラスを返す" do
    assert_equal :a, FooInfo5.first.key
  end

  it "キーは配列で指定するとアンダーバー付きのシンボルになる" do
    assert_equal [:id_desc], StaticRecord.create([{:key => [:id, :desc]}]).keys
  end

  it "対応するキーがなくなてもエラーにならない" do
    assert_nothing_raised { FooInfo1[:unknown] }
  end

  it "対応するキーがなければエラーになる" do
    assert_raises { FooInfo1.fetch(:unknown) }
  end

  it "再設定する" do
    obj = StaticRecord.define{[{key: :a}]}
    assert_equal [:a], obj.keys
    assert_equal [0], obj.codes
    obj.static_record_list_set [{key: :b}, {key: :c}]
    assert_equal [:b, :c], obj.keys
    assert_equal [0, 1], obj.codes
  end

  it "キーに日本語が使える" do
    obj = StaticRecord.define{[{key: "↑"}]}
    assert obj["↑"]
  end
end
