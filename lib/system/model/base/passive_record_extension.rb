# encoding: utf-8
module System::Model::Base

  module PassiveRecordExtension
    def self.included(mod)
      mod.cattr_accessor :column_names
      mod.cattr_accessor :columns
      mod.column_names ||= []
      mod.columns      ||= {}

      mod.extend(ClassMethods)
    end

    def to_xml(options = {})
      options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
      _with_class_name = options[:with_class_name] || false

      _root = options[:root] || self.class.model_name.singular

      xml = options[:builder]
      tag_attrs = {}
      tag_attrs[:class_name] = self.class.model_name if _with_class_name

      xml.tag!(_root, tag_attrs) do |n|

        key_type = key.class
        tag_attrs = {}
        tag_attrs[:class_name] = key.class.to_s if _with_class_name
        case key
        when String then n.tag!(:key, tag_attrs){|c| c.cdata! self.key }
        else n.tag!(:key, key, tag_attrs)
        end

        column_names.each do |colname|
          _col_type = columns[colname]
          tag_attrs = {}
          tag_attrs[:class_name] = _col_type if _with_class_name

          case _col_type.name
          when "String" then n.tag!(colname, tag_attrs){|c| c.cdata! self[colname] }
          when "Array" then n.tag!(colname, tag_attrs){|c| self[colname].each_with_index{|e,i| c.tag!(:element, e.to_s, {:index => i})} }
          when "Hash" then n.tag!(colname, tag_attrs){|c| self[colname].each{|k,v| c.tag!(:entry, v.to_s, {:key => k})} }
          else n.tag!(colname, self[colname].to_s, tag_attrs)
          end
        end
      end
    end

    module ClassMethods

      def define_columns
        yield self

        schema columns
      end

      def define_column(column_name, column_type)
        raise "already exists \"#{column_name}\"" if columns.has_key? column_name

        columns[column_name] ||= column_type
        column_names << column_name
      end

      def to_options_array(options = {})
        label_key = options[:label_key] || :title
        value_key = options[:value_key] || :key
        sort_key  = options[:sort_key]  || :sort_no

        find(:all).sort_by{|n| n.send(sort_key)}.collect{|n| [n.send(label_key), n.send(value_key)] }
      end
    end
  end
end