class System::ProductSynchro < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content

  attr_accessor :product_ids

  belongs_to :product, :class_name => 'System::Product', :foreign_key => :product_id

  def states
    [['予定','plan'],['開始','start'],['中間データ作成中','temp'],['バックアップ中','back'],['同期中','sync'],['成功','success'],['失敗','failure']]
  end

  def state_label
    str = states.rassoc(self.state)
    str ? str[0] : ''
  end

  def execute(options = {:delay => true})
    version = Time.now.to_i

    items = []
    System::Product.where(:id => self.product_ids).order(:id).all.map do |product|
      item = System::ProductSynchro.new
      item.state = 'plan'
      item.product_id = product.id
      item.version = version
      item.plan_id = options[:plan_id] if options[:plan_id].present?
      item.save(:validate => false)
      items << item 
    end

    item = items.detect{|i| i.product.product_type == 'gw'}
    item.update_attributes(:state => 'start')

    if options[:delay]
      item.delay.execute_gw
    else
      item.execute_gw
    end

    return item
  end

  def execute_gw
    # 中間データ作成
    return unless self.create_temporary

    # 各プロダクトの状態を開始に変更
    return unless self.class.where(["version = ? and id != ?", self.version, self.id]).update_all(:state => 'start')

    # バックアップ
    return unless self.backup_table

    # 同期
    self.synchronize
  end

protected

  def create_temporary
    update_attributes(:state => 'temp')

    results = System::LdapTemporary.create_temporary(self.version)

    messages = []
    messages << "グループ #{results[:group]}件"
    messages << "-- 失敗 #{results[:gerr]}件" if results[:gerr] > 0
    messages << "ユーザ #{results[:user]}件"
    messages << "-- 失敗 #{results[:uerr]}件" if results[:uerr] > 0
    update_attributes(:remark_temp => messages.join("\n"))

    if results[:gerr] > 0 || results[:uerr] > 0
      update_attributes(:state => 'failure')
      return false
    end

    return true
  end

  def backup_table
    update_attributes(:state => 'back')

    results = {:copy => 0, :cerr => 0}

    [:system_users, :system_groups, :system_users_groups, :system_group_histories, :system_users_group_histories].each do |table|
      begin
        conn = ActiveRecord::Base.connection
        conn.execute("DROP TABLE IF EXISTS #{table}_backups")
        conn.execute("CREATE TABLE #{table}_backups LIKE #{table}")
        conn.execute("INSERT INTO #{table}_backups SELECT * FROM #{table}")
        results[:copy] += 1
      rescue => e
        results[:cerr] += 1
      end
    end

    messages = []
    messages << "テーブル #{results[:copy]}件"
    messages << "--失敗 #{results[:cerr]}件" if results[:cerr] > 0
    update_attributes(:remark_back => messages.join("\n"))

    if results[:cerr] > 0
      update_attributes(:state => 'failure')
      return false
    end

    return true
  end

  def synchronize
    update_attributes(:state => 'sync')

    results = System::LdapTemporary.synchronize(self.version)

    messages = []
    messages << "--エラー\n#{results.join("\n")}" if results.size > 0
    update_attributes(:remark_sync => messages.join("\n"))

    if results.size > 0
      update_attributes(:state => 'failure')
      return false
    else
      update_attributes(:state => 'success')
      return true
    end
  end
end
