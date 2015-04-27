class Hcs::CheckupConfSetting < Hcs::CheckupDatabase
  include System::Model::Base
  include System::Model::Base::Content

  has_many :groups, :foreign_key => :conf_id, :class_name => "Hcs::CheckupConfGroup"
  has_many :enable_groups, -> { where(:state => 'enabled') }, :foreign_key => :conf_id, :class_name => "Hcs::CheckupConfGroup"
  has_many :applicable_groups, -> { where(:state => 'enabled', :exist_applicant => 1) }, :foreign_key => :conf_id, :class_name => 'Hcs::CheckupConfGroup'

  def show_reminder_title
    opts = [[0,''],[1,'定期検診'],[2,'人間ドック'],[3,'脳ドック'],[4,'特定検診'],[5,'その他'],[6,'被扶養者']]
    str = opts.assoc(self.reminder_title)
    str ? str[1] : ""
  end

  def enable_condition(options = {})
    self.and "#{self.class.table_name}.state", 'enabled'
    options.each_pair{|k,v| self.and k, v}
    self
  end

  def enable_reminder_condition(options = {})
    now = Time.now
    self.and "#{self.class.table_name}.state", 'enabled'
    self.and "#{self.class.table_name}.reminder", 1
    self.and "#{self.class.table_name}.end_time", '>', now
    self.and do |c|
      [0,1,2,3,4,5,6,7,14].each do |day|
        c.or do |c2|
          c2.and "#{self.class.table_name}.reminder_opt#{day}", 1
          c2.and "#{self.class.table_name}.end_time", '>=', (now + day.days).strftime("%Y/%m/%d 00:00:00")
          c2.and "#{self.class.table_name}.end_time", '<=', (now + day.days).strftime("%Y/%m/%d 23:59:59")
        end
      end
    end
    options.each_pair{|k,v| self.and k, v}
    self
  end

  def enable_fixed_reminder_condition(options = {})
    self.and "#{self.class.table_name}.state", 'enabled'
    self.and "#{self.class.table_name}.fixed_reminder", 1
    self.and "#{self.class.table_name}.fixed_start_at", '<=', Time.now
    self.and "#{self.class.table_name}.fixed_end_at", '>=', Time.now
    options.each_pair{|k,v| self.and k, v}
    self
  end

  def self.enable_items(options = {}, order = nil)
    item = self.new.enable_condition(options)
    item.order(order || 'checkup_kind, checkup_type')

    item.find(:all, :conditions => item.condition.where)
  end

  def self.enable_reminder_items(options = {}, order = nil)
    if options[:user_group].blank?
      user_group = Core.user_group.code
    else
      user_group = options[:user_group]
    end
    options.delete(:user_group)
    item = self.new.enable_reminder_condition(options)
    item.order(order || "#{self.table_name}.checkup_kind, #{self.table_name}.checkup_type")

    items = item.find(:all, :conditions => item.condition.where, :include => :applicable_groups)

    items.to_a.delete_if do |item|
      !item.applicable_groups.index{|g| g.group_code == user_group.code}
    end
    items
  end

  def self.enable_fixed_reminder_items(options = {}, order = nil)

    if options[:user_group].blank?
      user_group = Core.user_group.code
    else
      user_group = options[:user_group]
    end
    options.delete(:user_group)
    item = self.new.enable_fixed_reminder_condition(options)
    item.order(order || "#{self.table_name}.checkup_kind, #{self.table_name}.checkup_type")

    items = item.find(:all, :conditions => item.condition.where, :include => :applicable_groups)

    items.to_a.delete_if do |item|
      !item.applicable_groups.index{|g| g.group_code == user_group.code}
    end
    items
  end

end