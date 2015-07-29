# encoding: utf-8
module System::Model::Base

  def self.included(mod)
    mod.table_name = mod.to_s.underscore.gsub('/', '_').downcase.pluralize
    mod.extend(ClassMethods)
    mod.before_save :after_validation
  end


  def locale(name)
    label = I18n.t name, :scope => [:activerecord, :attributes, self.class.to_s.underscore]
    return label =~ /^translation missing:/ ? name.to_s.humanize : label
  end


  def after_validation
    return errors.size == 0 ? true : false
  end

  def to_xml(options = {})
    options[:dasherize] = false
    super
  end

  @cb_condition = nil
  @cb_extention = nil

  def condition
    @cb_condition = Condition.new() unless @cb_condition
    return @cb_condition
  end

  def cb_condition_where
    attributes.each {|col, val| self.and /\./ =~ col ? col : "#{self.class.table_name}.#{col}", val if val }
    condition.where
  end

  def cb_extention
    @cb_extention = {} unless @cb_extention
    return @cb_extention
  end

  def and(*args, &block)
    condition.and(*args, &block)
  end

  def or(*args, &block)
    condition.or(*args, &block)
  end

  def and_in_ssv(column, value)
    condition.and column, 'REGEXP', "(^| )#{value}( |$)"
  end

  def join(condition)
    cb_extention[:joins] = [] unless cb_extention[:joins]
    cb_extention[:joins] << condition
    cb_extention[:joins] = cb_extention[:joins].uniq
  end

  def order(columns, default = nil)
    if columns.to_s != ''
      cb_extention[:order] = columns
    elsif default.to_s != ''
      cb_extention[:order] = default
    end
  end

  def group_by(columns)
    cb_extention[:group] = [] unless cb_extention[:group]
    cb_extention[:group] << columns
    cb_extention[:group] = cb_extention[:group].uniq
  end

  def page(page, limit = 30)
    if limit.to_s == '0'
      cb_extention.delete :page
      cb_extention.delete :limit
    else
      page = 1 unless page.to_s =~ /^[1-9][0-9]*$/
      cb_extention[:page]  = page
      cb_extention[:limit] = limit
    end
  end

  def find(*args)
    scope   = args.slice!(0)
    options = args.slice!(0) || {}
    options[:conditions] = cb_condition_where   unless options[:conditions]
    options[:joins]      = cb_extention[:joins] unless options[:joins]
    options[:order]      = cb_extention[:order] unless options[:order]
    options[:group]      = cb_extention[:group] unless options[:group]

    ext = cb_extention
    return self.class.find(scope, options) unless ext[:page]

    options[:page]     = ext[:page]
    options[:per_page] = ext[:limit]
    return self.class.paginate(options)
  end

  def count(*args)
    options     = {}
    column_name = :all

    case args.size
    when 1
      args[0].is_a?(Hash) ? options = args[0] : column_name = args[0]
    when 2
      column_name, options = args
    else
      raise ArgumentError, "Unexpected parameters passed to count(): #{args.inspect}"
    end if args.size > 0

    options[:conditions] = cb_condition_where unless options[:conditions]
    return self.class.count(column_name, options)
  end

  def save_with_direct_sql
    quote = Proc.new do |val|
      self.class.connection.quote(val)
    end

    sql = "INSERT INTO #{self.class.table_name} (" + "\n"
    sql += self.class.column_names.sort.join(',')
    sql += ") VALUES (" + "\n"
    i = 0
    attributes.sort.each do |attr|
      sql += ',' if i != 0
      if attr[1] == nil
        sql += 'NULL'
      elsif attr[1].class == Time
        sql += "'#{attr[1].strftime('%Y-%m-%d %H:%M:%S')}'"
      else
        sql += quote.call(attr[1])
      end
      i += 1
    end
    sql += ")"
    self.class.connection.execute(sql)

    return true
  end


  module ClassMethods
    def escape_like(s)
      s.gsub(/[\\%_]/) {|r| "\\#{r}"}
    end
  end

end