# -*- coding: utf-8 -*-
# 少ない数のレコードを配列やハッシュとして管理するライブラリ
#
#     class Foo
#       include StaticRecord
#       static_record [
#         {:key => :left,  :name => "左", :vector => -1},
#         {:key => :right, :name => "右", :vecotr => 1},
#       ], :attr_reader => [:name, :vector]
#     end
#
#     Foo[0].key     # => :left
#     Foo[0].name    # => "左"
#     Foo[0].vector  # => -1
#     Foo[0].code    # => 0
#
#     Foo.count           # => 2
#     Foo.collect(&:name) # => "左", "右"
#
require "active_support/concern"
require "active_support/core_ext/class/attribute"
require "active_support/core_ext/array/wrap"
require "active_model"

module StaticRecord
  extend ActiveSupport::Concern

  def self.define(**options, &block)
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
    def static_record(list, **options, &block)
      return if static_record_defined?

      extend ActiveModel::Translation
      extend Enumerable
      include SingletonMethods

      class_attribute :static_record_configuration
      self.static_record_configuration = {
        :attr_reader => [],
      }.merge(options)

      if block_given?
        yield static_record_configuration
      end

      Array.wrap(options[:attr_reader]).each do |key|
        define_method(key) { @attributes[key.to_sym] }
      end

      unless method_defined?(:name)
        define_method(:name) { self.class.human_attribute_name(key) }
      end

      static_record_list_set(list)
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
      #
      #   Foo[0]            # => object
      #   Foo[:a]           # => object
      #   Foo[0] == Foo[:a] # => true
      #
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
            raise KeyError, "#{name}.fetch(#{key.inspect}) では何にもマッチしません。\nkeys: #{keys.inspect}\ncodes: #{codes.inspect}"
          end
        end
        v
      end

      def each(&block)
        @values.each(&block)
      end

      def keys
        @keys ||= @values_hash[:key].keys
      end

      def codes
        @codes ||= @values_hash[:code].keys
      end

      attr_reader :values

      def static_record_list_set(list)
        @keys = nil
        @codes = nil
        @values = list.collect.with_index {|e, i| new(e.merge(:_index => i)) }.freeze
        @values_hash = {}
        [:code, :key].each do |pk|
          @values_hash[pk] = @values.inject({}) {|a, e| a.merge(e.send(pk) => e) }
        end
      end

      private

      def lookup(key)
        if key.kind_of? self
          return key
        end
        case key
        when Symbol, String
          @values_hash[:key][key.to_sym]
        else
          @values_hash[:code][key]
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
