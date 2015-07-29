# encoding: utf-8
class Gw::Script::Tool
  require 'csv'
  require 'pp'
  require 'yaml'

  def self.backup_databases(prefix='dev')
    dbs = []
    Gw::Schedule.connection.execute(%Q(show databases like '#{prefix}_jgw_%';)).each{|x| dbs.push x[0]}
    env = Hash[*'dev:development:pre:production:devpro:development_debug'.split(':').to_a]
    env_s = Gw.nz(env[prefix],prefix)
    dbconfig = ActiveRecord::Base.configurations[env_s]
    dbs.each do |db|
      fn = "_wrk/#{db.sub(/^#{prefix}_/, '')}.sql"
      %x(mysqldump -u #{dbconfig['username']} --password=#{dbconfig['password']} #{db} > #{fn})
    end
  end

  def self.restore_databases(prefix='dev')
    dbs = []
    Gw::Schedule.connection.execute(%Q(show databases like '#{prefix}_jgw_%';)).each{|x| dbs.push x[0]}
    fns = Dir["_wrk/jgw_*.sql"]
    env = Hash[*'dev:development:pre:production:devpro:development_debug'.split(':').to_a]
    env_s = Gw.nz(env[prefix],prefix)
    dbconfig = ActiveRecord::Base.configurations[env_s]
    mysql_core_s = "mysql -u #{dbconfig['username']} --password=#{dbconfig['password']}"
    fns.sort.each do |fn|
      db = %Q[#{prefix}_#{fn.sub(/^_wrk\//, '').sub(/\.sql$/, '')}]
      sqlex = %Q(#{mysql_core_s} #{db} < #{fn})
      if dbs.index(db).nil?
        p "creating database #{db}"
        sql_create = %Q(echo create database #{db}|#{mysql_core_s})
        p sql_create
        ret_create_db = %x(#{sql_create})
      end
      ret_restore = %x(#{sqlex})
    end
  end

  def self.import_csv_if(filename, csv_setting_name)
    f = open(filename).read
    s_to = import_csv(f, csv_setting_name)
    puts s_to
  end

  def self.import_csv(input_csv, csv_setting_name,options={})
    validation  = true
    unless options.blank?
      if options.has_key?(:valid)
        validation  = options[:valid]
      end
    end
    stamps  = true
    unless options.blank?
      if options.has_key?(:stamps)
        stamps  = options[:stamps]
      end
    end
    hash_raw = YAML.load_file('config/locales/csv_settings.yml')
    if csv_setting_name
      csv = []
      CSV.parse(input_csv) do |row|
        csv.push row
      end
      setting = hash_raw[csv_setting_name]
      raise TypeError, 'unknown csv_setting_name' if setting.nil?
      model = eval(setting['model'])
      fields = setting['fields']
      csv_titles = csv[0]
      csv.shift
      ln = 0
      ln_t = 0
      ln_f = 0
      ret = ''
      if stamps==false
        model.record_timestamps = false
      end
      csv.each do |x|
        model_n = model.new
        ln += 1
        fields.keys.each do |y|
          idx = csv_titles.index(y)
          eval "model_n.#{fields[y]} = x[idx]"
        end
        if model_n.save(:validate => validation)
          ln_t += 1
        else
          ln_f += 1
          tmp = ''
          PP.pp x, tmp
          ret += "Error Line #{ln}: " + tmp
        end
      end
      if stamps==false
        model.record_timestamps = true
      end
      ret = "#{ln} lines parsed. #{ln_t} imported, #{ln_f} failed." + ret
      return ret
    end
  end

  def self.export_csv_if(m_fr, options={})
    a_ar = m_fr.find(:all)
    s_to = self.ar_to_csv(a_ar, options)
    puts s_to
  end

  def self.get_trans_hash(trans_hash_raw, hash_name, action)
    trans_hash = {}
    unless hash_name.blank?
      trans_hash_org = trans_hash_raw[hash_name]
      return {} if trans_hash_org.blank?
      trans_hash_org = trans_hash_raw[trans_hash_org['_base']] unless trans_hash_org['_base'].nil?
      trans_hash_common = {}
      trans_hash_common = trans_hash_org['_common'] if !trans_hash_org.nil? && !trans_hash_org['_common'].nil?
      trans_hash_action = {}
      trans_hash_action = trans_hash_org['show'] if !trans_hash_org.nil? && action == 'form' && !trans_hash_org['show'].nil?
      trans_hash = trans_hash_org.dup.reject{|k,v| v.is_a?(Hash)}.merge(trans_hash_common).merge(trans_hash_action)
      trans_hash_action = trans_hash_org[action] if !trans_hash_org.nil? && !trans_hash_org[action].nil?
      trans_hash = trans_hash_org.dup.reject{|k,v| v.is_a?(Hash)}.merge(trans_hash_common).merge(trans_hash_action)
    end
    return trans_hash
  end

  def self.ar_to_csv(a_ar, _options={})
    options = HashWithIndifferentAccess.new(_options)
    return [] if a_ar.nil? || a_ar == []
    trans_hash_raw = Gw.load_yaml_files
    action = Gw.nz(options[:action], 'csvput')
    unless options['table_name'].nil?
      hash_name = options['table_name']
    else
      if a_ar.is_a?(ActiveRecord::Base)
        hash_name = a_ar.class.table_name
      elsif a_ar.is_a?(WillPaginate::Collection)
        hash_name = a_ar.last.class.table_name
      elsif a_ar.is_a?(Array)
        hash_name = a_ar.last.class.table_name if a_ar.last.is_a?(ActiveRecord::Base)
      end
    end
    trans_hash = self.get_trans_hash(trans_hash_raw, hash_name, action)
    cols = !options[:columns].nil? ? options[:columns] :
      !options[:cols].nil? ? options[:cols] :
      !trans_hash['_cols'].nil? ? trans_hash['_cols'].split(':') :
      a_ar.last.class.column_names.sort == a_ar.last.attribute_names.sort ? a_ar.last.class.column_names : a_ar.last.attribute_names
    cols = options[:cols].split(',') if cols.is_a?(String)
    opt_quotes = options[:quotes].nil? ? true : options[:quotes]
    opt_header = options[:header].nil? ? true : options[:header]

    col_types_all = a_ar.last.class.columns.collect{|x| [x.name, x.type]}
    col_types = cols.collect{|x| col_types_all.assoc(x)}
    idx = 0
    date_fld_idxs = []
    col_types.each_with_index do |col, idx|
      date_fld_idxs.push idx if col[1] == :datetime
    end
    ret = opt_header ? [cols] : []
    a_ar.each do |r|
      ret_1 = []
      cols.each_with_index do |col, idx|
        ret_1.push date_fld_idxs.index(idx).nil? ? r.send(col) : Gw.date_format('%Y/%m/%d %X', r.send(col))
      end
      ret.push ret_1
    end
    csv_string = CSV.generate(:force_quotes => opt_quotes) do |csv|
      ret.each do |x|
        csv << x
      end
    end
    csv_string = NKF::nkf('-s', csv_string) if options[:kcode] == 'sjis'
    csv_string = NKF::nkf(options[:nkf], csv_string) unless options[:nkf].nil?
    return csv_string
  end

  def self.ary_to_csv(a_ary, _options={})
    options = HashWithIndifferentAccess.new(_options)
    return [] if a_ary.nil? || a_ary == []
    opt_quotes = options[:quotes].nil? ? true : options[:quotes]
    opt_header = options[:header].nil? ? nil : options[:header]

    ret = !opt_header.nil? ? [opt_header] : []
    a_ary.each do |r|
      ret.push r
    end
    csv_string = CSV.generate(:force_quotes => opt_quotes) do |csv|
      ret.each do |x|
        csv << x
      end
    end
    csv_string = NKF::nkf('-s', csv_string) if options[:kcode] == 'sjis'
    csv_string = NKF::nkf(options[:nkf], csv_string) unless options[:nkf].nil?
    return csv_string
  end

  def self.ldap_xml_to_csv(filename)
    f = open(filename).read
    hx = self.from_ldap_xml(f)
    s_to = self.to_csv(hx)
    puts s_to
  end

  def self.notes_xml_to_csv(filename)
    f = open(filename).read
    hx = self.from_notes_xml(f)
    s_to = self.to_csv(hx)
    puts s_to
  end

  def self.notes_view_xml_to_csv(filename, mode='view')
    f = open(filename).read
    hx = self.from_notes_view_xml(f, mode)
    s_to = self.to_csv2(hx)
    puts s_to
  end

  def self.notes_item_xml_to_csv(filename)
    f = open(filename).read
    hx = self.from_notes_view_xml(f, 'item')
    s_to = self.to_csv2(hx)
    puts s_to
  end

  def self.from_ldap_xml(xml)
    preprocess_from_xml
    hxs = self.undasherize_keys(self.xml_in_string(xml,
      'forcearray'   => false,
      'forcecontent' => true,
      'keeproot'     => true,
      'contentkey'   => '__content__'))
    ret = []
    hxs['ROOT']['row'].each do |hx|
      hx['field'].each do |hxwx|
        hx[hxwx['name']] = hxwx['__content__']
      end
      hx.delete('field')
      ret.push hx
    end
    return ret
  end

  def self.from_notes_xml(xml)
    preprocess_from_xml
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

  def self.from_notes_view_xml(xml, mode='view')
    preprocess_from_xml
    hxs = self.undasherize_keys(self.xml_in_string(xml,
      'forcearray'   => false,
      'forcecontent' => true,
      'keeproot'     => true,
      'contentkey'   => '__content__'))
    ret = []
    case hxs['database']['doc'].class.to_s
    when 'Array'
      hxs['database']['doc'].each do |hx|
        hw = parse_notes_view(hx, mode)
        ret.push hw unless hw.blank?
      end
    else
      raise TypeError, "Unknown Type: #{hxs['database']['doc'].class}"
    end unless hxs['database']['doc'].nil?
    return ret
  end

  def self.parse_notes_view(hx, mode='view')
    hx.delete('title')
    m1 = mode
    m2 = mode == 'view' ? 'item' : 'view'
    hx.delete(m2)
    hx[m1].each do |hxwx|
      hx[hxwx['name']] = hxwx['__content__'] if hxwx['name'] !~ /^\$/ # $ ではじまる項目は捨てる
    end unless hx[m1].nil?
    hx.delete(m1)
    if hx['file'].nil?
      hx["attachment_file_num"] = 0
    else
      case hx['file'].class.to_s
      when 'Hash'
        hx["attachment_file_num"] = 1
      when 'Array'
        hx["attachment_file_num"] = hx['file'].length
      end
    end
    hx.delete('file')
    return hx
  end

  def self.parse_notes_doc(hx)
    hx.delete('view')
    hx['item'].each do |hxwx|
      hx[hxwx['name']] = hxwx['__content__'] if hxwx['name'] !~ /^\$/ # $ ではじまる項目は捨てる
    end unless hx['item'].nil?
    hx.delete('item')
    idx = 0
    if hx['file'].nil?
    else
      case hx['file'].class.to_s
      when 'Hash'
        hx["attachment_filename_1"] = hx['file']['filename']
      when 'Array'
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
          retx.push Gw.nz(hxx[key],'')
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

    return csv_string
  end

  def self.to_csv2(hx, delim=',', cr = "\n")
    case
    when hx.is_a?(Hash)
      h_keys = []
      h_keys.push hx.keys
      h_keys.flatten!
      h_keys.uniq!
      h_keys.sort!
      ret = []
      ret.push h_keys.sort
      retx = []
      h_keys.each do |key|
        retx.push Gw.nz(hx[key],'')
      end
      ret.push retx
    when hx.is_a?(Array)
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
          retx.push Gw.nz(hxx[key],'')
        end
        ret.push retx
      end
    else
      raise TypeError, "不明な型です(#{hx.class})"
    end

    csv_string = CSV.generate(:force_quotes => true) do |csv|
      ret.each do |x|
        csv << x
      end
    end

    return csv_string
  end

private
  def self.undasherize_keys(params)
    case params.class.to_s
      when "Hash"
        params.inject({}) do |h,(k,v)|
          h[k.to_s.tr("-", "_")] = undasherize_keys(v)
          h
        end
      when "Array"
        params.map { |v| undasherize_keys(v) }
      else
        params
    end
  end

  def self.xml_in_string(string, options = nil)
    self.handle_options('in', options)

    @doc = parse(string)
    result = collapse(@doc.root)

    if @options['keeproot']
      merge({}, @doc.root.name, result)
    else
      result
    end
  end

  def self.handle_options(direction, options)
    @options = options || Hash.new

    raise ArgumentError, "Options must be a Hash!" unless @options.instance_of?(Hash)

    unless @@known_options.has_key?(direction)
      raise ArgumentError, "Unknown direction: <#{direction}>."
    end

    known_options = @@known_options[direction]
    @options = normalize_option_names(@options, known_options)

    unless @default_options.nil?
      known_options.each { |option|
        unless @options.has_key?(option)
          if @default_options.has_key?(option)
            @options[option] = @default_options[option]
          end
        end
      }
    end

    unless @options.has_key?('noattr')
        @options['noattr'] = false
    end

    if @options.has_key?('rootname')
      @options['rootname'] = '' if @options['rootname'].nil?
    else
      @options['rootname'] = @@def_root_name
    end

    if @options.has_key?('xmldeclaration') && @options['xmldeclaration'] == true
      @options['xmldeclaration'] = @@def_xml_declaration
    end

    @options['keytosymbol'] = @@def_key_to_symbol unless @options.has_key?('keytosymbol')

    if @options.has_key?('contentkey')
      if @options['contentkey'] =~ /^-(.*)$/
        @options['contentkey']    = $1
        @options['collapseagain'] = true
      end
    else
      @options['contentkey'] = @@def_content_key
    end

    unless @options.has_key?('normalisespace')
      @options['normalisespace'] = @options['normalizespace']
    end
    @options['normalisespace'] = 0 if @options['normalisespace'].nil?

    if @options.has_key?('searchpath')
      unless @options['searchpath'].instance_of?(Array)
        @options['searchpath'] = [ @options['searchpath'] ]
      end
    else
      @options['searchpath'] = []
    end

    if @options.has_key?('cache') && scalar(@options['cache'])
      @options['cache'] = [ @options['cache'] ]
    end

    @options['anonymoustag'] = @@def_anonymous_tag unless @options.has_key?('anonymoustag')

    if !@options.has_key?('indent') || @options['indent'].nil?
      @options['indent'] = @@def_indentation
    end

    @options['indent'] = '' if @options.has_key?('noindent')

    if @options.has_key?('keyattr')
      if !scalar(@options['keyattr'])
        if @options['keyattr'].instance_of?(Hash)
          @options['keyattr'].each { |key, value|
            if value =~ /^([-+])?(.*)$/
              @options['keyattr'][key] = [$2, $1 ? $1 : '']
            end
          }
        elsif !@options['keyattr'].instance_of?(Array)
          raise ArgumentError, "'keyattr' must be String, Hash, or Array!"
        end
      else
        @options['keyattr'] = [ @options['keyattr'] ]
      end
    else
      @options['keyattr'] = @@def_key_attributes
    end

    if @options.has_key?('forcearray')
      if @options['forcearray'].instance_of?(Regexp)
        @options['forcearray'] = [ @options['forcearray'] ]
      end

      if @options['forcearray'].instance_of?(Array)
        force_list = @options['forcearray']
        unless force_list.empty?
          @options['forcearray'] = {}
          force_list.each { |tag|
            if tag.instance_of?(Regexp)
              unless @options['forcearray']['_regex'].instance_of?(Array)
                @options['forcearray']['_regex'] = []
              end
              @options['forcearray']['_regex'] << tag
            else
              @options['forcearray'][tag] = true
            end
          }
        else
          @options['forcearray'] = false
        end
      else
        @options['forcearray'] = @options['forcearray'] ? true : false
      end
    else
      @options['forcearray'] = @@def_force_array
    end

    if @options.has_key?('grouptags') && !@options['grouptags'].instance_of?(Hash)
      raise ArgumentError, "Illegal value for 'GroupTags' option - expected a Hash."
    end

    if @options.has_key?('variables') && !@options['variables'].instance_of?(Hash)
      raise ArgumentError, "Illegal value for 'Variables' option - expected a Hash."
    end

    if @options.has_key?('variables')
      @_var_values = @options['variables']
    elsif @options.has_key?('varattr')
      @_var_values = {}
    end
  end

  def self.normalize_option_names(options, known_options)
    return nil if options.nil?
    result = Hash.new
    options.each { |key, value|
      lkey = key.downcase
      lkey.gsub!(/_/, '')
      if !known_options.member?(lkey)
        raise ArgumentError, "Unrecognised option: #{lkey}."
      end
      result[lkey] = value
    }
    result
  end

  def self.parse(xml_string)
    require 'rexml/document'
    REXML::Document.new(xml_string)
  end

  def self.collapse(element)
    result = @options['noattr'] ? {} : get_attributes(element)

    if @options['normalisespace'] == 2
      result.each { |k, v| result[k] = normalise_space(v) }
    end

    if element.has_elements?
      element.each_element { |child|
        value = collapse(child)
        if empty(value) && (element.attributes.empty? || @options['noattr'])
          next if @options.has_key?('suppressempty') && @options['suppressempty'] == true
        end
        result = merge(result, child.name, value)
      }
      if has_mixed_content?(element)
        content = element.texts.map { |x| x.to_s }
        content = content[0] if content.size == 1
        result[@options['contentkey']] = content
      end
    elsif element.has_text? # i.e. it has only text.
      return collapse_text_node(result, element)
    end

    count = fold_arrays(result)

    if @options.has_key?('grouptags')
      result.each { |key, value|
        next unless (value.instance_of?(Hash) && (value.size == 1))
        child_key, child_value = value.to_a[0]
        if @options['grouptags'][key] == child_key
          result[key] = child_value
        end
      }
    end

    if count == 1
      anonymoustag = @options['anonymoustag']
      if result.has_key?(anonymoustag) && result[anonymoustag].instance_of?(Array)
        return result[anonymoustag]
      end
    end

    if result.empty? && @options.has_key?('suppressempty')
      return @options['suppressempty'] == '' ? '' : nil
    end

    result
  end

  def self.get_attributes(node)
    attributes = {}
    node.attributes.each { |n,v| attributes[n] = v }
    attributes
  end

  def self.collapse_text_node(hash, element)
    value = node_to_text(element)
    if empty(value) && !element.has_attributes?
      return {}
    end

    if element.has_attributes? && !@options['noattr']
      return merge(hash, @options['contentkey'], value)
    else
      if @options['forcecontent']
        return merge(hash, @options['contentkey'], value)
      else
        return value
      end
    end
  end

  def self.node_to_text(node, default = nil)
    if node.instance_of?(REXML::Element)
      node.texts.map { |t| t.value }.join('')
    elsif node.instance_of?(REXML::Attribute)
      node.value.nil? ? default : node.value.strip
    elsif node.instance_of?(REXML::Text)
      node.value.strip
    else
      default
    end
  end

  def self.empty(value)
    case value
      when Hash
        return value.empty?
      when String
        return value !~ /\S/m
      else
        return value.nil?
    end
  end

  def self.merge(hash, key, value)
    if value.instance_of?(String)
      value = normalise_space(value) if @options['normalisespace'] == 2

      unless @_var_values.nil? || @_var_values.empty?
        value.gsub!(/\$\{(\w+)\}/) { |x| get_var($1) }
      end

      if @options.has_key?('varattr')
        varattr = @options['varattr']
        if hash.has_key?(varattr)
          set_var(hash[varattr], value)
        end
      end
    end

    if @options.has_key?('keytosymbol')
      if @options['keytosymbol'] == true
        key = key.to_s.downcase.to_sym
      end
    end

    if hash.has_key?(key)
      if hash[key].instance_of?(Array)
        hash[key] << value
      else
        hash[key] = [ hash[key], value ]
      end
    elsif value.instance_of?(Array)
      hash[key] = [ value ]
    else
      if force_array?(key)
        hash[key] = [ value ]
      else
        hash[key] = value
      end
    end
    hash
  end

  def self.force_array?(key)
    return false if key == @options['contentkey']
    return true if @options['forcearray'] == true
    forcearray = @options['forcearray']
    if forcearray.instance_of?(Hash)
      return true if forcearray.has_key?(key)
      return false unless forcearray.has_key?('_regex')
      forcearray['_regex'].each { |x| return true if key =~ x }
    end
    return false
  end

  def self.fold_arrays(hash)
    fold_amount = 0
    keyattr = @options['keyattr']
    if (keyattr.instance_of?(Array) || keyattr.instance_of?(Hash))
      hash.each { |key, value|
        if value.instance_of?(Array)
          if keyattr.instance_of?(Array)
            hash[key] = fold_array(value)
          else
            hash[key] = fold_array_by_name(key, value)
          end
          fold_amount += 1
        end
      }
    end
    fold_amount
  end

  def self.has_mixed_content?(element)
    if element.has_text? && element.has_elements?
      return true if element.texts.join('') !~ /^\s*$/s
    end
    false
  end

  def self.fold_array(array)
    hash = Hash.new
    array.each { |x|
      return array unless x.instance_of?(Hash)
      key_matched = false
      @options['keyattr'].each { |key|
        if x.has_key?(key)
          key_matched = true
          value = x[key]
          return array if value.instance_of?(Hash) || value.instance_of?(Array)
          value = normalise_space(value) if @options['normalisespace'] == 1
          x.delete(key)
          hash[value] = x
          break
        end
      }
      return array unless key_matched
    }
    hash = collapse_content(hash) if @options['collapseagain']
    hash
  end

  def self.preprocess_from_xml()
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
end
