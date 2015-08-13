# -*- coding: utf-8 -*-
require 'spec_helper'

class Model
  include StaticRecord
  static_record [
    {:name => "A"},
    {:name => "B"},
  ], :attr_reader => :name
end

class Legacy
  include StaticRecord
  static_record [
    {:code => 10, :key => :a, :name => "A"},
    {:code => 20, :key => :b, :name => "B"},
  ], :attr_reader => :name
end

RSpec.describe StaticRecord do
  let(:instance) { Model.first }

  context "便利クラスメソッド" do
    it "each" do
      assert Model.each
    end

    it "keys" do
      assert_equal [:_key0, :_key1], Model.keys
    end

    it "values" do
      assert_equal Model.each.to_a, Model.values
    end
  end

  context "クラスに対しての添字アクセス" do
    it "コードもキーも自動で振る場合" do
      assert_equal "A", Model[0].name
    end

    it "対応するキーがなくなてもエラーにならない" do
      assert_nothing_raised { Model[:unknown] }
    end

    it "fetchの場合、対応するキーがなければエラーになる" do
      assert_raises { Model.fetch(:unknown) }
    end
  end

  context "インスタンスに対しての添字アクセス" do
    it do
      instance[:name].should == "A"
      instance[:xxxx].should == nil
    end
  end

  context "to_s" do
    it do
      instance.to_s.should == "A"
    end
  end

  context "インスタンスのアクセサー" do
    it do
      assert instance.attributes
      assert instance.key
      assert instance.code
    end
  end

  context "再設定" do
    before do
      @model = StaticRecord.define{[{key: :a}]}
      @model.static_record_list_set [{key: :b}, {key: :c}]
    end
    it "変更できている" do
      assert_equal [:b, :c], @model.keys
      assert_equal [0, 1], @model.codes
    end
  end

  context "微妙な仕様" do
    it "create の使用例" do
      model = StaticRecord.create [{:key => :a}]
      assert_equal :a, model.first.key
    end

    it "define の使用例" do
      model = StaticRecord.define { [{:key => :a}] }
      assert_equal :a, model.first.key
    end

    it "キーは配列で指定するとアンダーバー付きのシンボルになる" do
      assert_equal [:id_desc], StaticRecord.create([{:key => [:id, :desc]}]).keys
    end

    it "nameメソッドは定義されてなければ自動的に定義" do
      model = StaticRecord.define { [] }
      assert_equal true, model.instance_methods.include?(:name)
    end
  end

  it "キーに日本語が使える" do
    model = StaticRecord.define{[{key: "あ"}]}
    assert model["あ"]
  end

  it "コードやキーは自分で定義する場合" do
    assert_equal "A", Legacy[10].name
  end
end
