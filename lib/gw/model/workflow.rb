module Gw::Model::Workflow

  def self.how_long_notifying
    # ひとまず 5日間を決裁/却下のリマインダー表示期間とする
    # 10.hour <-たとえば10時間にするならこうかく
    5.day
  end

  def self.remind(user = Core.user)
    to_reminders(user).map{|title, date|
      {
      :date_str => date.strftime("%m/%d %H:%M"),
      :cls => 'ワークフロー',
      :title => title,
      :date_d => date
      }
    }
  end

  def self.remind_xml(user, xml_data = nil)
    to_reminders(user).each{|title, date|
      xml_data  << %Q(<entry>)
      xml_data  << %Q(<link rel="alternate" href="/gwworkflow"/>)
      xml_data  << %Q(<updated>#{date.strftime('%Y-%m-%d %H:%M:%S')}</updated>)
      xml_data  << %Q(<category term="workflow">ワークフロー</category>)
      xml_data  << %Q(<title>#{title}</title>)
      xml_data  << %Q(</entry>)
    }
    return xml_data
  end

  def self.to_reminders(user)
    undecided_docs(user) + accepted_docs(user) + rejected_docs(user) + remanded_docs(user)
  end

  def self.undecided_docs(user)
    docs = Gwworkflow::Doc.where(state: 'applying').user_processing_docs(user)
    if docs.length == 0
      []
    else
      [["<a href='/gwworkflow/docs?cond=processing'>承認待ち稟議書が #{docs.length} 件あります。</a>", docs.map(&:updated_at).max]]
    end
  end

  def self.accepted_docs(user)
    docs = Gwworkflow::Doc.where(creater_id: user.id, state: 'accepted').updated_after(Time.now - how_long_notifying)
    docs.map {|doc| ["<a href='/gwworkflow/docs/#{doc.id}'>「#{doc.title}」 が決裁されました。</a>", doc.updated_at] }
  end

  def self.rejected_docs(user)
    docs = Gwworkflow::Doc.where(creater_id: user.id, state: 'rejected').updated_after(Time.now - how_long_notifying)
    docs.map {|doc| ["<a href='/gwworkflow/docs/#{doc.id}'>「#{doc.title}」 が却下されました。</a>", doc.updated_at] }
  end

  def self.remanded_docs(user)
    docs = Gwworkflow::Doc.where(creater_id: user.id, state: 'remanded').updated_after(Time.now - how_long_notifying)
    docs.map {|doc| ["<a href='/gwworkflow/docs/#{doc.id}'>「#{doc.title}」 が差し戻されました。</a>", doc.updated_at] }
  end
end
