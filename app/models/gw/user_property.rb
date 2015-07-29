# -*- encoding: utf-8 -*-
class Gw::UserProperty < Gw::Database
  #establish_connection :dev_jgw_gw rescue nil
  include System::Model::Base
  include System::Model::Base::Content

  scope :gwmonitor_help_links, :conditions => {:class_id => 3, :name => 'gwmonitor', :type_name => 'help_link'}

  def is_email_mobile?
    return false if self.options.blank? || self.name != 'mobile'

    options = JsonParser.new.parse(self.options)
    if !options['mobiles'].blank? && !options['mobiles']['kmail'].blank? && !options['mobiles']['ktrans'].blank?
      if options['mobiles']['ktrans'] == '1' && Gw::MemoMobile.is_email_mobile?(options['mobiles']['kmail'])
        return true
      end
    end
    return false

  end

  def self.is_todos_display?

    raise "Do not call the method!!"

    todos_display = false
    todo_settings = Gw::Model::Schedule.get_settings 'todos', {}
    if todo_settings.key?(:todos_display_schedule)
      todos_display = true if todo_settings[:todos_display_schedule].to_s == '1'
    end
    return todos_display
  end

  def self.load_gwmonitor_help_links
    help = self.gwmonitor_help_links.find(:first)

    helps = JsonParser.new.parse(help.options) rescue Array.new(3, [''])
    helps.map{|item| item[0].to_s}
  end
end
