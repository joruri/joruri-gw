class System::Script::ProductSynchroPlan < System::Script::Base

  def self.check
    run do
      plans = System::ProductSynchroPlan.arel_table
      item = System::ProductSynchroPlan.where(plans[:state].eq('plan'))
        .where(plans[:start_at].lteq(Time.now)).order(:start_at).first
      log "予定なし" and next if item.blank?

      log "プロダクト同期処理: #{item.class}: id: #{item.id}" do
        item.update_attribute(:state, 'start')
        sync = System::ProductSynchro.new(:product_ids => item.product_ids) 
        sync.execute(:delay => false, :plan_id => item.id)
        item.update_attribute(:state, 'end')
      end
    end
  end
end
