class Cms::Lib::Base < ActiveRecord::Base
  include Cms::Lib::CheckDigit
  include Cms::Lib::Xml

  def self.object_finder
    finder = self.new
    finder.reset_object_finder
    finder.enable_object_finder
    return finder
  end

  def table_name
    self.class.table_name
  end

  def reset_object_finder
    @object_finder_model    = self.class
    @object_finder_where    = []
    @object_finder_join     = nil
    @object_finder_order    = nil
    @object_finder_offset   = nil
    @object_finder_limit    = nil
    @object_finder_page     = nil
  end

  def enable_object_finder
    @object_finder = true
  end

  def new(values = {})
    return @object_finder_model.new(values)
  end

  def find(*arguments)
    scope   = arguments.slice!(0)
    options = arguments.slice!(0) || {}

    if @object_finder_page
      options = {
        :conditions => finder_conditions,
        :joins      => @object_finder_join,
        :page       => @object_finder_page,
        :per_page   => @object_finder_limit,
        :order      => @object_finder_order || nil
      }
      return @object_finder_model.paginate(options)
    else
      options[:conditions] = finder_conditions
      options[:joins]      = @object_finder_join
      options[:order] = @object_finder_order unless options[:order]
      return @object_finder_model.find(scope, options)
    end
  end

  def paginate(page, per_page = 20)
    @object_finder_page  = page || 1
    @object_finder_limit = per_page
  end

  def count
    return @object_finder_model.count(:conditions => finder_conditions)
  end

  def order(column, sort = nil)
    @object_finder_order = column
    @object_finder_order += ' ' + sort.upcase if sort && sort.downcase =~ /asc|desc/
  end

  def where(*arguments)
    scope = [arguments.slice!(0)].to_s
    scope = scope.gsub(/\{self\}/, '`' + table_name + '`')
    condition = [scope]
    condition << arguments.slice!(0) unless arguments.empty?
    @object_finder_where << condition
  end

  def join(*arguments)
    @object_finder_join = arguments
  end

  def finder_conditions(op = "and")
    return nil if @object_finder_where.empty?
    ps = []
    conditions = @object_finder_where.collect do |c|
      next if c.size < 1
      ps += c[1..(c.size)]
      "( #{c[0]} )"
    end.delete_if { |c| c.blank? }.join(" #{op} ")
    [conditions, ps].flatten unless conditions.empty?
  end

  def search(sv)
  end

  def get(name)
    self.send(name)
  rescue ActiveRecord::RecordNotFound
    ''
  end
end