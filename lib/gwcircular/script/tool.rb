# -*- encoding: utf-8 -*-
class Gwcircular::Script::Tool
  require 'fastercsv'

  def self.commission_output_list(a_ar, options={})
    return [] if a_ar.nil? || a_ar == []
    if options[:cols].nil?
      cols1 = a_ar.last.class.column_names
      cols2 = a_ar.last.attribute_names
      cols = cols1.length == cols2.length ? cols1 : cols2
    else
      case options[:cols].class.to_s
      when 'String'
        cols = options[:cols].split(',')
      when 'Array'
        cols = options[:cols]
      else
        raise TypeError, "cols が異常です(#{options[:cols].class})"
      end
    end
    opt_header = options[:header].nil? ? true : options[:header]

    col_types_all = a_ar.last.class.columns.collect{|x| [x.name, x.type]}
    col_types = cols.collect{|x| col_types_all.assoc(x)}
    idx = 0
    date_fld_idxs = []
    col_types.each_with_index do |col, idx|
#      date_fld_idxs.push idx if col[1] == :datetime
    end
    ret = opt_header ? [cols] : []
    a_ar.each do |r| # AR record
      ret_1 = []
      cols.each_with_index do |col, idx|
        ret_1.push r.send(col)
      end
      ret.push ret_1
    end
    return ret
  end

  def self.commission_to_csv(a_ar, options={})
    opt_quotes = options[:quotes].nil? ? true : options[:quotes]
    ret = commission_output_list(a_ar, options)
    csv_string = FasterCSV.generate(:force_quotes => opt_quotes) do |csv|
      ret.each do |x|
        csv << x
      end
    end
    csv_string = NKF::nkf('-s', csv_string) if options[:kcode] == 'sjis'
    csv_string = NKF::nkf(options[:nkf], csv_string) unless options[:nkf].nil?
    return csv_string
  end

end
