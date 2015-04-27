class Gw::Script::ScheduleProp < System::Script::Base

  def self.cancel_timeup
    run do
      daytime = Time.now - 30.minutes

      log "レンタカー自動キャンセル処理: #{I18n.l(daytime)}より前の予約をキャンセル" do
        items = Gw::ScheduleProp.where(prop_type: 'Gw::PropRentcar', extra_data: nil)
          .where(['(st_at > updated_at and st_at < ?) or (st_at <= updated_at and updated_at < ?)', daytime, daytime])
          .order(st_at: :asc, prop_id: :asc)
        can = 0
        items.each do |item|
          if cancel_rentcar(item, daytime)
            can += 1
          end
        end
        log "#{can} cancelled"
      end
    end
  end

  def self.cancel_rentcar(item, daytime)
    # キャンセル対象と判定された予約の、1つ前の予約を検索する
    item_sub = Gw::ScheduleProp.where(prop_type: 'Gw::PropRentcar', prop_id: item.prop_id)
      .where(["st_at < ? and (extra_data not like '%\"cancelled\":1%' or extra_data is null)", item.st_at])
      .order(st_at: :desc).first

    cancel_flg = 
      # 直前の存在がなければ、無条件でキャンセル
      if item_sub.blank?
        true
      else
        # 1つ前の予約が、返却済み以上ならキャンセルを実行。キャンセルのprop_statは900なので、1つ前の予約がキャンセルの場合はキャンセルが実行される。
        if item_sub.prop_stat.to_i > 3
          true
        # 返却済みの時は、その返却時間が現時刻の30分前よりさらに前の時にキャンセルを実行する。
        elsif item_sub.prop_stat.to_i == 3
          item_sub.ed_at < daytime
        else
          false
        end
      end

    cancel_flg && item.cancell! && item.save
  end
end
