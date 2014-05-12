# -*- coding: utf-8 -*-
# 定数の名前を参照できない問題に対応するためのモジュール
#
#   一般的な使い方
#
#     class FooInfo
#       include StaticRecord
#       static_record [
#         {:code => 1, :key => :a, :name => "A"},
#         {:code => 2, :key => :b, :name => "B"},
#         {:code => 3, :key => :c, :name => "C"},
#       ], :attr_reader => :name
#     end
#
#     class Card
#       def foo_info
#         FooInfo[foo_code]
#       end
#     end
#
#   全体を取得するときは Enumerable 系メソッドがあるのでどうにでもなる
#     配列化
#       FooInfo.each{|v|...}
#     フォームのプルダウンに出すとき
#       <%= form.collection_select(:foo_code, FooInfo, :code, :name) %>
#
#   ダイレクトに参照するには？
#
#     FooInfo[1].name  # => "A"
#     FooInfo[:a].name # => "A"
#
#   インスタンスメソッドは code と key は必ず存在する。
#
#     object = FooInfo[:a]
#     object.key  # => :a
#     object.code # => 1
#
#     あと引数に渡したものを単純にメソッド化する :attr_reader => :name を指定していたら、
#
#       object.name # => "A"
#
#     も使える
#
#     あと :a ならランダムで赤っぽい色を返したいような場合は、そういうインスタンスメソッドを定義すればいい
#     (ただ、なるべくポルモルフィックにして冗長な条件分岐は避けること)
#
#     name の別名で to_s を定義しているので name のままでいいなら "#{foo_info}" と書ける
#
#     key と code も空なら自動的に振っていく(空にするカラムはすべてのレコードを未指定にしておくこと)
#

require "active_support/concern"
require "active_support/core_ext/class/attribute"
require "active_support/core_ext/array/wrap"
require "active_model"

require "static_record/version"

module StaticRecord
  extend ActiveSupport::Concern

  def self.define(options = {}, &block)
    Class.new do
      include StaticRecord
      static_record block.call, options
    end
  end

  def self.create(*args, &block)
    Class.new do
      include StaticRecord
      static_record *args, &block
    end
  end

  module ClassMethods
    def static_record(list, options = {}, &block)
      return if static_record_defined?

      extend ActiveModel::Translation
      extend Enumerable
      include SingletonMethods

      class_attribute :static_record_configuration
      self.static_record_configuration = {
        :attr_reader => [],    # 提供するインターフェイス
      }.merge(options)

      if block_given?
        yield static_record_configuration
      end

      # code と key は指定がなければインデックスを元にしたユニークな値を割り振っていく
      Array.wrap(options[:attr_reader]).each do |k|
        define_method(k) { @attributes[k.to_sym] }
      end

      # @pool も @pool_hash も外部アクセサを定義しないこと(重要)

      # code の初期値が欲しいので内部でインデックスを持つ
      @pool = list.collect.with_index{|a, i|new(a.merge(:_index => i))}

      # O(1) で引くためのテーブルを用意
      @pool_hash = {
        :codes => @pool.inject({}){|h, v| h.merge(v.code => v) },
        :keys  => @pool.inject({}){|h, v| h.merge(v.key => v) },
      }

      # name に反応できなければ key からの翻訳をデフォルトにする(オーバーライド推奨)
      unless method_defined?(:name)
        define_method(:name) { self.class.human_attribute_name(key) }
      end
    end

    def static_record_defined?
      ancestors.include?(SingletonMethods)
    end
  end

  module SingletonMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def static_record?
        static_record_defined?
      end

      # 直接参照
      #   FooInfo[0]                # => object
      #   FooInfo[:a]               # => object
      #   FooInfo[0] == FooInfo[:a] # => true
      def [](arg)
        lookup(arg)
      end

      # [] と同じだけど戻値がなければ例外を投げる
      def fetch(key, default = nil, &block)
        raise ArgumentError if block_given? && default
        v = lookup(key)
        unless v
          case
          when block_given?
            v = yield
          when default
            v = default
          else
            raise KeyError, "#{name}.fetch(#{key.inspect}) では何にもマッチしません。\nkeys: #{keys.inspect}, codes: #{codes.inspect}"
          end
        end
        v
      end

      # FooInfo.each{|foo_info|...}
      def each(&block)
        @pool.each(&block)
      end

      def keys
        @keys ||= @pool_hash[:keys].keys
      end

      def codes
        @codes ||= @pool_hash[:codes].keys
      end

      def values
        @pool
      end

      private

      def lookup(key)
        if key.kind_of? self
          return key
        end
        case key
        when Symbol, String
          @pool_hash[:keys][key.to_sym]
        else
          @pool_hash[:codes][key]
        end
      end
    end

    attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes

      if @attributes[:key]
        if @attributes[:key].kind_of? Array
          @attributes[:key] = @attributes[:key].join("_")
        end
        @attributes[:key] = @attributes[:key].to_sym
      end
    end

    def code
      @attributes[:code] || @attributes[:_index]
    end

    def key
      @attributes[:key] || "_key#{@attributes[:_index]}".to_sym
    end

    def to_s
      name
    end

    def [](v)
      @attributes[v]
    end
  end
end
