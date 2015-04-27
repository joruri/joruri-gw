require 'csv'
module System::Model::Serializer::Csv
  extend ActiveSupport::Concern

  module ClassMethods
    def to_csv(options = {}, csv_options = {})
      headers = options.key?(:headers) ? options[:headers] : csv_headers(options)
      columns = options.key?(:columns) ? options[:columns] : csv_columns(options)
      CSV.generate(csv_options.reverse_merge(force_quotes: true)) do |csv|
        csv << headers if headers.present?
        all.each do |item|
          if block_given?
            csv << yield(item)
          else
            csv << item.attributes.values_at(*columns)
          end
        end
      end
    end

    def from_csv(str, options = {}, csv_options = {})
      items = []
      headers = options.key?(:headers) ? options[:headers] : csv_headers(options)
      columns = options.key?(:columns) ? options[:columns] : csv_columns(options)
      CSV.parse(str, csv_options.reverse_merge(headers: true)).each do |row|
        if block_given?
          items << yield(row)
        else
          item = self.new
          headers.each_with_index {|header, i| item.send("#{columns[i]}=", row[header]) }
          items << item
        end
      end
      items
    end

    private

    def csv_i18n(option)
      option == :default ? model_name.i18n_key : option
    end

    def csv_columns(options = {})
      if options[:i18n_key]
        I18n.t("csv.headers.#{csv_i18n(options[:i18n_key])}").keys.map(&:to_s)
      else
        columns = column_names.dup
        columns.reject! {|name| name.in?(options[:except].map(&:to_s)) } if options[:except]
        columns.select! {|name| name.in?(options[:only].map(&:to_s)) } if options[:only]
        columns
      end
    end

    def csv_headers(options = {})
      if options[:i18n_key]
        I18n.t("csv.headers.#{csv_i18n(options[:i18n_key])}").values
      else
        csv_columns(options)
      end
    end
  end
end
