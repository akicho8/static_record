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

describe do
  it "コードやキーは自分で定義する場合" do
    FooInfo1[10].name.should == "A"
  end

  it "コードもキーも自動で振る場合" do
    FooInfo2[0].name.should == "A"
  end

  it "キーの配列だけ欲しい" do
    FooInfo2.keys.should == [:_key0, :_key1]
  end

  it "値の配列" do
    FooInfo2.values.should == FooInfo2.each.to_a
  end

  it "name メソッドは自動的に定義" do
    FooInfo3.instance_methods.include?(:name).should == true
  end

  it "create で無名クラスを返す" do
    FooInfo4.first.key.should == :a
  end

  it "define で無名クラスを返す" do
    FooInfo5.first.key.should == :a
  end

  it 'should have a version number' do
    StaticRecord::VERSION.should_not be_nil
  end

  it "キーは配列で指定するとアンダーバー付きのシンボルになる" do
    StaticRecord.create([{:key => [:id, :desc]}]).keys.should == [:id_desc]
  end

  it "添字や結果がおかしいときエラーにしたりしなかったり" do
    expect { FooInfo1.find(:unknown) }.to raise_error(ArgumentError)
    FooInfo1.safe_find(:unknown).should == nil
  end
end
