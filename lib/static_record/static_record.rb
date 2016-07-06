# frozen_string_literal: true
require "active_support/concern"
require "active_support/core_ext/module/concerning"
require "active_support/core_ext/class/attribute"
require "active_support/core_ext/array/wrap"
require "active_model"

module StaticRecord
  class << self
    def define(**options, &block)
      Class.new do
        include StaticRecord
        static_record block.call, options
      end
    end

    def create(*args, &block)
      Class.new do
        include StaticRecord
        static_record *args, &block
      end
    end
  end

  extend ActiveSupport::Concern

  class_methods do
    def static_record(list, **options, &block)
      return if static_record_defined?

      extend ActiveModel::Translation
      extend Enumerable
      include ::StaticRecord::SingletonMethods

      class_attribute :static_record_configuration
      self.static_record_configuration = {
        :attr_reader => [],
      }.merge(options)

      if block_given?
        yield static_record_configuration
      end

      if static_record_configuration[:attr_reader_auto]
        _attr_reader = list.inject([]) { |a, e| a | e.keys.collect(&:to_sym) }
      else
        _attr_reader = static_record_configuration[:attr_reader]
      end

      include Module.new.tap { |m|
        ([:key, :code] + Array.wrap(_attr_reader)).uniq.each do |key|
          m.class_eval do
            define_method(key) { @attributes[key.to_sym] }
          end
        end

        unless m.method_defined?(:name)
          m.class_eval do
            define_method(:name) { self.class.human_attribute_name(key) }
          end
        end
      }

      static_record_list_set(list)
    end

    def static_record_defined?
      ancestors.include?(SingletonMethods)
    end
  end

  concern :SingletonMethods do
    class_methods do
      def static_record?
        static_record_defined?
      end

      def lookup(key)
        return key if key.kind_of? self
        case key
        when Symbol, String
          @values_hash[:key][key.to_sym]
        else
          @values_hash[:code][key]
        end
      end
      alias [] lookup

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

      delegate :each, :to => :values

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
        @values = list.collect.with_index {|e, i| new(_attributes_normalize(e, i)) }.freeze
        @values_hash = {}
        [:code, :key].each do |pk|
          @values_hash[pk] = @values.inject({}) {|a, e| a.merge(e.send(pk) => e) }
        end
      end

      private

      def _attributes_normalize(attrs, index)
        key = attrs[:key] || "_key#{index}".freeze
        if key.kind_of? Array
          key = key.join("_")
        end
        attrs.merge(:code => attrs[:code] || index, :key => key.to_sym)
      end
    end

    attr_reader :attributes

    delegate :[], :to => :attributes
    delegate :to_s, :to => :name

    def initialize(attributes)
      @attributes = attributes.inject({}) {|a, (k, v)| a.merge(k.freeze => v ? v.freeze : v) }
    end
  end
end
