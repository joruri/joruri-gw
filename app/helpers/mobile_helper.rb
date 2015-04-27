module MobileHelper

  def latest_memo_count
    Gw::Memo.with_receiver(Core.user).only_unfinished.count
  end

  def mail_tag
    recent_mail = session[:recent_mail]
    if recent_mail == "0" or recent_mail.blank? or recent_mail == "-1"
      tag = 0
    else
      tag = recent_mail.to_i
    end
    return tag
  end

  def group_enabled_children(group_id)
    items = System::Group.where(:parent_id => group_id, :state => "enabled").order(:sort_no)

    return items
  end

end
