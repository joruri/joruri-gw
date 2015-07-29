# encoding: utf-8
class Gw::ScheduleUser < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :schedule, :foreign_key => :schedule_id, :class_name => 'Gw::Schedule', :touch => true
  belongs_to :user, :foreign_key => :uid, :class_name => 'System::User'
  belongs_to :group, :foreign_key => :uid, :class_name => 'System::Group'

  def schedule_before_destroy
    fields = Array.new
    values = Array.new

    self.class.columns.each do |column|
      fields << "`#{column.name}`"

      column_data = nz(eval("self.#{column.name}"), "null")
      if column_data == 'null'
        values << "#{column_data}"
      elsif column.type == :datetime
        column_data = column_data.strftime("%Y-%m-%d %H:%M:%S")
        values << "'#{column_data}'"
      else
        values << "'#{column_data}'"
      end
    end

    fields << "`destroy_at`"
    values << "'#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'"
    fields << "`destroy_uid`"
    values << "'#{Site.user.id}'"

    sql_fields = fields.join(',')
    sql_values = values.join(',')
    sql = "INSERT INTO gw_destroy_schedule_users (#{sql_fields}) VALUES (#{sql_values})"

    connection.execute(sql)
  end

  def get_object
    case class_id
    when 1
      self.user
    when 2
      self.group
    end
  end

  def get_object_name
    case class_id
    when 1
      "#{self.user.name} (#{self.user.code})"
    when 2
      self.group.name
    end
  end

  def self.user_exist_check(schedule_id = nil, uid = Site.user.id)
    return false if schedule_id.blank?
    item = Gw::ScheduleUser.new.find(:first, :conditions => "schedule_id = #{schedule_id} and class_id = 1 and uid = #{uid}")

    if item.blank?
      return false
    else
      return true
    end
  end

  def self.users_view(items, options = {})
    caption = nz(options[:caption])
    include_table_tag = true if options[:include_table_tag].nil?

    ret = ''
    ret.concat '<table class="show">' if include_table_tag
    ret.concat %Q(<tr><th colspan="2">#{caption}</th></tr>) if caption
    items.each do |x|
      begin
        case x.class_id
        when 0
          th = 'すべて'
          td = ''
        when 1
          th = 'ユーザー'
          user = System::User.find(:first, :conditions => "id=#{x.uid}")
          if user.blank? || user.state != 'enabled'
            td = ''
          else
            td = user.display_name
          end

        when 2
          th = 'グループ'
          group = System::Group.find(:first, :conditions => "id=#{x.uid}")
          if group.blank? || group.state != 'enabled'
            td = ''
          else
            td = group.name
          end

        end
        ret.concat "<tr><th>#{th}</th><td>#{td}</td></tr>" unless td.blank?
      rescue
      end
    end
    ret.concat '</table>' if include_table_tag
    return ret
  end
end
