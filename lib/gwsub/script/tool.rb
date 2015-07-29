# -*- encoding: utf-8 -*-
class Gwsub::Script::Tool
  require 'csv'
  require 'pp'
  require 'yaml'

  # sb04　担当一覧 登録時限定
  def self.import_csv_sb04_assignedjobs(input_csv, csv_setting_name)
    hash_raw = YAML.load_file('config/locales/csv_settings.yml')
    if csv_setting_name
      csv = []
      CSV.parse(input_csv) do |row|
        csv.push row
      end
      setting = hash_raw[csv_setting_name]
      raise TypeError, 'unknown csv_setting_name' if setting.nil?
      model = eval(setting['model']) #TODO/090616/nkoshiba: eval 危険
      fields = setting['fields']
      csv_titles = csv[0]
      csv.shift
      ln = 0
      ln_t = 0
      ln_f = 0
      ret = ''
      csv.each do |x|
        model_n = model.new
        ln += 1
        fields.keys.each do |y|
          idx = csv_titles.index(y)
          case fields[y]
          when 'section_code'
            section_no6 = x[idx]
            eval "model_n.#{fields[y]} = '#{section_no6.to_s}'"
          else
            eval "model_n.#{fields[y]} = x[idx]"
          end
        end

        if model_n.save(:validate=>false)
          ln_t += 1
        else
          ln_f += 1
          tmp = ''
          PP.pp x, tmp
          ret += "Error Line #{ln}: " + tmp
        end
      end
      ret = "#{ln} lines parsed. #{ln_t} imported, #{ln_f} failed." + ret
      return ret
    end
  end
  # sb04　所属一覧 登録時限定
  def self.import_csv_sb04_section(input_csv, csv_setting_name)
    hash_raw = YAML.load_file('config/locales/csv_settings.yml')
    if csv_setting_name
      csv = []
      CSV.parse(input_csv) do |row|
        csv.push row
      end
      setting = hash_raw[csv_setting_name]
      raise TypeError, 'unknown csv_setting_name' if setting.nil?
      model = eval(setting['model']) #TODO/090616/nkoshiba: eval 危険
      fields = setting['fields']
      csv_titles = csv[0]
      csv.shift
      ln = 0
      ln_t = 0
      ln_f = 0
      ret = ''
      csv.each do |x|
        model_n = model.new
        ln += 1
        fields.keys.each do |y|
          idx = csv_titles.index(y)
          case fields[y]
          when 'code'
            section_no6 = x[idx]
            eval "model_n.#{fields[y]} = '#{section_no6.to_s}'"
          when 'ldap_code'
            section_no5 = x[idx]
            eval "model_n.#{fields[y]} = '#{section_no5.to_s}'"
          else
            eval "model_n.#{fields[y]} = x[idx]"
          end
        end
        if model_n.save(:validate=>false)
          ln_t += 1
        else
          ln_f += 1
          tmp = ''
          PP.pp x, tmp
          ret += "Error Line #{ln}: " + tmp
        end
      end
      ret = "#{ln} lines parsed. #{ln_t} imported, #{ln_f} failed." + ret
      return ret
    end
  end

  # sb04　職員一覧 登録時限定
  def self.import_csv_sb04_staff(input_csv, csv_setting_name)
    hash_raw = YAML.load_file('config/locales/csv_settings.yml')
    if csv_setting_name
      csv = []
      CSV.parse(input_csv) do |row|
        csv.push row
      end
      setting = hash_raw[csv_setting_name]
      raise TypeError, 'unknown csv_setting_name' if setting.nil?
      model = eval(setting['model']) #TODO/090616/nkoshiba: eval 危険
      fields = setting['fields']
      csv_titles = csv[0]
      csv.shift
      ln = 0
      ln_t = 0
      ln_f = 0
      ret = ''
      csv.each do |x|
        model_n = model.new
        ln += 1
        fields.keys.each do |y|
          idx = csv_titles.index(y)
          case fields[y]
          when 'staff_no'
            staff_no7 = x[idx]
            eval "model_n.#{fields[y]} = '#{staff_no7.to_s}'"
          when 'section_code'
            section_no6 = x[idx]
            eval "model_n.#{fields[y]} = '#{section_no6.to_s}'"
          else
            eval "model_n.#{fields[y]} = x[idx]"
          end
        end
        if model_n.save(:validate=>false)
          ln_t += 1
        else
          ln_f += 1
          tmp = ''
          PP.pp x, tmp
          ret += "Error Line #{ln}: " + tmp
        end
      end
      ret = "#{ln} lines parsed. #{ln_t} imported, #{ln_f} failed." + ret
      return ret
    end
  end

  def self.stafflistview_output_list(a_ar, options={})

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
    # main
    col_types_all = a_ar.last.class.columns.collect{|x| [x.name, x.type]}
    col_types = cols.collect{|x| col_types_all.assoc(x)}
    idx = 0
    date_fld_idxs = []
    col_types.each_with_index do |col, idx|
      date_fld_idxs.push idx if col[1] == :datetime
    end
    ret = opt_header ? [cols] : []
    sections = nil
    jobs = nil
    a_ar.each do |r| # AR record
      ret_1 = []
      cols.each do |col|
        #見出し行挿入判定
        case col
        when 'section_name'
#        pp [col,r.send(col),sections,jobs]
          if sections.to_s == r.send(col).to_s
          else
            #見出し行挿入
            line = Gwsub::Script::Tool.set_lines(r,cols,'1',sections,jobs)
            ret.push  line[0]
            sections  = line[1]
            jobs      = line[2]
          end
        when 'assignedjobs_name'
          if jobs.to_s == r.send(col).to_s
          else
          #見出し行挿入
            line = Gwsub::Script::Tool.set_lines(r,cols,'2',sections,jobs)
            ret.push  line[0]
            sections  = line[1]
            jobs      = line[2]
          end
        else
        end
      end
      cols.each_with_index do |col, idx|
        case col
        when 'section_name'
          ret_1.push nil
        when 'assignedjobs_address'
          ret_1.push nil
        when 'assignedjobs_name'
          ret_1.push nil
        when 'assignedjobs_tel'
          ret_1.push nil
        else
          ret_1.push r.send(col)
        end
      end
      ret.push ret_1
    end
    return ret
  end

  def self.stafflistview_to_csv(a_ar, options={})
    opt_quotes = options[:quotes].nil? ? true : options[:quotes]
    ret = stafflistview_output_list(a_ar, options)
    csv_string = CSV.generate(:force_quotes => opt_quotes) do |csv|
      ret.each do |x|
        csv << x
      end
    end
    csv_string = NKF::nkf('-s', csv_string) if options[:kcode] == 'sjis'
    csv_string = NKF::nkf(options[:nkf], csv_string) unless options[:nkf].nil?
    return csv_string
  end

  def self.set_lines(r,cols,b,sections,jobs)
    lines = []
    section = sections.to_s
    job     = jobs.to_s
    cols.each do |col|
      case col
      when 'section_name'
        section =  r.send(col).to_s
        if b == '1'
          lines.push r.send(col)
        else
          lines.push nil
        end
      when 'assignedjobs_address'
        lines.push r.send(col)
      when 'assignedjobs_name'
        job =  r.send(col).to_s
        lines.push r.send(col)
      when 'assignedjobs_tel'
        lines.push r.send(col)
      else
        lines.push nil
      end
    end
    return [lines,section,job]
  end

  def self.notes_xml_to_csv(filename)
    f = open(filename).read
    hx = self.from_notes_xml(f)
    s_to = self.to_csv(hx)
    return s_to
  end

  def self.from_notes_xml(xml)
    preprocess_from_xml
    # pass1: xml から hash に変換
    hxs = self.undasherize_keys(self.xml_in_string(xml,
      'forcearray'   => false,
      'forcecontent' => true,
      'keeproot'     => true,
      'contentkey'   => '__content__'))
    ret = []
    case hxs['database']['doc'].class.to_s
    when 'Hash'
      hw = parse_notes_doc(hxs['database']['doc'])
      ret.push hw unless hw.blank?
    when 'Array'
      hxs['database']['doc'].each do |hx|
        hw = parse_notes_doc(hx)
        ret.push hw unless hw.blank?
      end
    end unless hxs['database']['doc'].nil?
    return ret
  end
  def self.parse_notes_doc(hx)
    # view は notes の表示上の見出し項目指定なので捨てる
    hx.delete('view')
    # データベース情報の parse
    hx['item'].each do |hxwx|
      hx[hxwx['name']] = hxwx['__content__'] if hxwx['name'] !~ /^\$/ # $ ではじまる項目は捨てる
    end unless hx['item'].nil?
    hx.delete('item')
    # 添付ファイル情報の parse
    idx = 0
    if hx['file'].nil?
      # 添付ファイルなし
    else
      case hx['file'].class.to_s
      when 'Hash'
        # 添付ファイル1個
        hx["attachment_filename_1"] = hx['file']['filename']
      when 'Array'
        # 添付ファイル2個以上
        hx['file'].each do |hxwx|
          idx += 1
          hx["attachment_filename_#{idx}"] = hxwx['filename']
        end
      end
    end
    hx.delete('file')
    return hx
  end
  def self.to_csv(hx, delim=',', cr = "\n")
    case
    when hx.is_a?(Hash)
      h_keys = []
      hx.each do |hxx|
        h_keys.push hxx.keys
      end
      h_keys.flatten!
      h_keys.uniq!
      h_keys.sort!
      ret = []
      ret.push h_keys.sort
      hx.each do |hxx|
        retx = []
        h_keys.each do |key|
          retx.push nz(hxx[key],'')
        end
        ret.push retx
      end
    when hx.is_a?(Array)
      ret = hx
    else
      raise TypeError, "不明な型です(#{hx.class})"
    end
    csv_string = CSV.generate(:force_quotes => true) do |csv|
      ret.each do |x|
        csv << x
      end
    end
    # csv_string = ret.to_csv # <= 2d array に未対応
    return csv_string
  end
  def self.preprocess_from_xml()
    # TODO: Refactor this into something much cleaner that doesn't rely on XmlSimple
    @@xml_parsing = {
      "symbol"       => Proc.new  { |symbol|  symbol.to_sym },
      "date"         => Proc.new  { |date|    ::Date.parse(date) },
      "datetime"     => Proc.new  { |time|    ::Time.parse(time).utc rescue ::DateTime.parse(time).utc },
      "integer"      => Proc.new  { |integer| integer.to_i },
      "float"        => Proc.new  { |float|   float.to_f },
      "decimal"      => Proc.new  { |number|  BigDecimal(number) },
      "boolean"      => Proc.new  { |boolean| %w(1 true).include?(boolean.strip) },
      "string"       => Proc.new  { |string|  string.to_s },
      "yaml"         => Proc.new  { |yaml|    YAML::load(yaml) rescue yaml },
      "base64Binary" => Proc.new  { |bin|     ActiveSupport::Base64.decode64(bin) },
      "file"         => Proc.new do |file, entity|
        f = StringIO.new(ActiveSupport::Base64.decode64(file))
        f.extend(FileLike)
        f.original_filename = entity['name']
        f.content_type = entity['content_type']
        f
      end

    }
    @@known_options = {
      'in'  => %w(
        keyattr keeproot forcecontent contentkey noattr
        searchpath forcearray suppressempty anonymoustag
        cache grouptags normalisespace normalizespace
        variables varattr keytosymbol
      ),
      'out' => %w(
        keyattr keeproot contentkey noattr rootname
        xmldeclaration outputfile noescape suppressempty
        anonymoustag indent grouptags noindent
      )
    }
    @@def_key_attributes  = []
    @@def_root_name       = 'opt'
    @@def_content_key     = 'content'
    @@def_xml_declaration = "<?xml version='1.0' standalone='yes'?>"
    @@def_anonymous_tag   = 'anon'
    @@def_force_array     = true
    @@def_indentation     = '  '
    @@def_key_to_symbol   = false
  end

  def self.get_start_at
    fyears = Gwsub::Sb0904FiscalYearSetting.find(:first , :order=>"start_at DESC")
    if fyears.blank?
      return nil
    end
    if fyears.start_at.blank?
      return nil
    end
    if fyears.start_at.strftime("%Y-%m-%d 00:00:00") <= Time.now.strftime("%Y-%m-%d 00:00:00")
      return nil
    end
    return fyears.start_at.strftime('%Y-%m-%d 00:00:00')
  end
end
