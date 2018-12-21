module System::Model::Base::ConditionBuilder
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
      ordering_columns = columns
    elsif default.to_s != ''
      ordering_columns = default
    end
    ordering_columns = []
    ordering_columns.split(/,/).each do |c|
      column, direction = c.split(/ /)
      ordering_columns << "#{sanitize_column(column)} #{sanitize_column_direction(direction)}"
    end
    cb_extention[:order] = ordering_columns.join(', ')
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
    options[:include]    = cb_extention[:include] unless options[:include]
    options[:order]      = cb_extention[:order] unless options[:order]
    options[:group]      = cb_extention[:group] unless options[:group]
    options[:select]     = cb_extention[:select] unless options[:select]
    ext = cb_extention
    ret = self.class
    ret = ret.joins(options[:joins]) if options[:joins]
    ret = ret.includes(options[:include]) if options[:include]
    ret = ret.where(options[:conditions]) if options[:conditions]
    ret = ret.references(options[:include]) if options[:include]
    ret = ret.select(options[:select]) if options[:select]
    ret = ret.order(options[:order]) if options[:order]
    ret = ret.group(options[:group]) if options[:group]
    if ext[:page]
      options[:page]     = ext[:page]
      options[:per_page] = ext[:limit]
      ret = ret.paginate(page: options[:page],per_page: options[:per_page])
      return ret
    else
      if scope == :first
        return ret.first
      elsif scope == :all
        return ret
      else
        return self.class.where(self.class.primary_key => scope).first
      end
    end
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
    ret = self.class
    ret = ret.joins(options[:joins]) if options[:joins]
    ret = ret.includes(options[:include]) if options[:include]
    ret = ret.where(options[:conditions]) if options[:conditions]
    ret = ret.references(options[:include]) if options[:include]
    ret = ret.select(options[:select]) if options[:select]
    ret = ret.order(options[:order]) if options[:order]
    ret = ret.group(options[:group]) if options[:group]
    if scope == :first
      return ret.first.count
    elsif scope == :all
      return ret.count
    else
      return ret.count
    end
    #return self.class.count(column_name, options)
  end

  private
  def sanitize_column(column)
    self.class.column_names.each{|a| return a if a == column}
    return "id"
  end

  def sanitize_column_direction(direction)
    return 'ASC' if direction.blank?
    direction = direction.upcase
    ['DESC', 'ASC'].include?(direction) ? direction : "DESC"
  end

end
