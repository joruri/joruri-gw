class Gwsub::Sb05DesiredDate < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :m_rel ,:foreign_key=> :media_id ,:class_name=>'Gwsub::Sb05MediaType'

  validates_presence_of   :media_code,:desired_at
  validates_uniqueness_of :desired_at ,:scope=>:media_code  ,:message=>'は、登録済です。'
#  gw_validates_datetime   :desired_at

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns
  before_save   :before_save_set_self

  def before_save_set_self
    require 'date'
    d_at = self.desired_at
    date = Gw.get_parsed_date(d_at)

    m_cond = "state=1 and media_code=#{self.media_code}"
    m_order = "media_code,categories_code"
    media = Gwsub::Sb05MediaType.where(m_cond).order(m_order).first
    self.media_id = media.id
    self.weekday = self.desired_at.wday
    self.monthly = ((self.desired_at.strftime("%d").to_i - 1)/7).to_i + 1
    if self.edit_limit_at.blank?
      case self.media_code.to_i
      when 1
        check_at = date - 14*24*60*60 + 18*60*60
        self.edit_limit_at = Gw.get_parsed_date(check_at)
      when 2
        check_at = date - 14*24*60*60 + 18*60*60
        self.edit_limit_at = Gw.get_parsed_date(check_at)
      when 3
        check_at = date -  7*24*60*60 + 18*60*60
        self.edit_limit_at = Gw.get_parsed_date(check_at)
      when 4
        check_at = date -  7*24*60*60 + 15*60*60
        self.edit_limit_at = Gw.get_parsed_date(check_at)
      else
        check_at = Time.now
        self.edit_limit_at = Gw.get_parsed_date(check_at)
      end
    end
  end

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end

  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v, :desired_at
      when 'm_id'
        search_id v.to_i, :media_id unless (v.to_i == 0)
      when 'm_cd'
        search_id v.to_s, :media_code unless (v.to_s == '0' || v.to_s.blank? )
      end
    end if params.size != 0

    return self
  end

  def select_weekday_list
    Gw.yaml_to_array_for_select("gwsub_sb05_desired_dates_weekday_checkboxes")
  end

  def select_weekday_show
    list = select_weekday_list
    return nil if list.blank?
    list.each{|a| return a[0] if a[1] == weekday.to_i}
    return nil
  end


  def select_monthly_list
    Gw.yaml_to_array_for_select("gwsub_sb05_desired_dates_monthly_checkboxes")
  end

  def select_monthly_show
    list = select_monthly_list
    return nil if list.blank?
    list.each{|a| return a[0] if a[1] == monthly.to_i}
    return nil
  end


end
