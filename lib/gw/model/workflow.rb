# encoding: utf-8
module Gw::Model::Workflow

  def self.how_long_notifying
    # ひとまず 5日間を決裁/却下のリマインダー表示期間とする
    # 10.hour <-たとえば10時間にするならこうかく
    5.day
  end

  def self.remind(uid = Site.user.id)
    to_reminders(Gwworkflow::Doc.all, uid).map{|title, date|
      {
      :date_str => date.strftime("%m/%d %H:%M"),
      :cls => 'ワークフロー',
      :title => title,
      :date_d => date
      }
    }
  end
  
  
  def self.remind_xml(uid  , xml_data = nil)
    to_reminders(Gwworkflow::Doc.all, uid).each{|title, date|
      xml_data  << %Q(<entry>)
      xml_data  << %Q(<link rel="alternate" href="/gwworkflow"/>)
      xml_data  << %Q(<updated>#{date.strftime('%Y-%m-%d %H:%M:%S')}</updated>)
      xml_data  << %Q(<category term="workflow">ワークフロー</category>)
      xml_data  << %Q(<title>#{title}</title>)
      xml_data  << %Q(</entry>)
    }
    return xml_data
  end

  def self.to_reminders(docs, uid)
    undecided_workflows(docs,uid) + accepted_workflows(docs,uid) + rejected_workflows(docs,uid)
  end

  def self.undecided_workflows(docs, uid)
    xs = docs.select{|doc|doc.current_step}
      .select{|doc| doc.real_state == :applying }
      .map{|doc| doc.current_step.committee }
      .select{|c| c.user_id.to_i == uid }
      .select{|c| c.state.to_sym == :undecided }
    return [] if xs.length == 0
    [[ "<a href='#{Rails.application.routes.url_helpers.gwworkflow_path}?cond=processing'>承認待ち稟議書が #{xs.length} 件あります。</a>",
      xs.map{|x|x.updated_at}.max ]]
  end

  def self.accepted_workflows(docs, uid)
    docs.select{|doc| doc.creater_id.to_i == uid }
      .select{|doc| DateTime.now <= (doc.updated_at + self.how_long_notifying) }
      .select{|doc| doc.real_state.to_sym == :accepted }
      .map{|doc|
        [ "<a href='#{Rails.application.routes.url_helpers.gwworkflow_path}/show/#{doc.id}'>「#{doc.title}」 が決裁されました。</a>", doc.updated_at ]
      }
  end
  def self.rejected_workflows(docs, uid)
    docs.select{|doc| doc.creater_id.to_i == uid }
      .select{|doc| DateTime.now <= (doc.updated_at + self.how_long_notifying) }
      .select{|doc| doc.real_state.to_sym == :rejected }
      .map{|doc|
        [ "<a href='#{Rails.application.routes.url_helpers.gwworkflow_path}/show/#{doc.id}'>「#{doc.title}」 が却下されました。</a>", doc.updated_at ]
      }
  end
end
