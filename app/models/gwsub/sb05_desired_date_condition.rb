class Gwsub::Sb05DesiredDateCondition < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :m_rel ,:foreign_key=> :media_id ,:class_name=>'Gwsub::Sb05MediaType'

  validate :sel_validates

  def sel_validates
#    pp ['sel_validates',self]
    # 媒体区分の選択
    if self.media_id.to_i==0
      self.errors.add :media_id, "を選択してください"
    end

    # 週の選択
    w_or = self.w1 || self.w2 || self.w3 || self.w4 || self.w5
    if w_or == false
      self.errors.add :base, "週は、１つ以上を選択してください"
    end

    # 曜日の選択
    d_or = self.d0 || self.d1 || self.d2 || self.d3 || self.d4 || self.d5 || self.d6
    if d_or == false
      self.errors.add :base, "曜日は、１つ以上を選択してください"
    end

    # 開始日の入力
    if self.st_at.blank?
      self.errors.add :st_at, "を入力してください"
    else
      start_at = Gw.get_parsed_date(self.st_at)
      if start_at.blank?
        self.errors.add :st_at, "の書式は日付ではありません"
      else
        if start_at < Gw.get_parsed_date(Core.now)
          self.errors.add :st_at, "は将来日を設定してください"
        end
      end
    end

    # 終了日の入力
    if self.ed_at.blank?
      self.errors.add :ed_at, "を入力してください"
    else
      end_at = Gw.get_parsed_date(self.ed_at)
      if end_at.blank?
        self.errors.add :ed_at, "の書式は日付ではありません"
      else
        if end_at < Gw.get_parsed_date(Core.now)
          self.errors.add :ed_at, "は将来日を設定してください"
        end
      end
    end

    # 相関チェック
    if start_at.blank? or end_at.blank?
      # 開始・終了のどちらかがエラーの場合はスキップ
    else
      if start_at > end_at
        self.errors.add :ed_at, "は開始日より後の日付を入力してください"
      else
        limit_at = Gw.get_parsed_date(self.st_at + 60*60*24*365 )
        if end_at > limit_at
          self.errors.add :ed_at, "は開始日から１年以内の日付を入力してください"
        end
      end
    end
  end

end
