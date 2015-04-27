module Gwsub::Controller::Recgnize
  #############################################
  #承認処理に必要な機能
  #管理者へのリマインダー通知のみ、各紺コントローラーで設定
  #基本的にitem => SbxxRecognizer.new
  #############################################

  #承認者リスト
  #def users_collection(group_id)
  #  @users_collection = []
  #  sql = Condition.new
  #  sql.and "sql", "system_users_groups.group_id = #{group_id}"
#    join = "INNER JOIN system_users_groups ON system_users.id = system_users_groups.user_id"
    # 同一所属内で無効ユーザーを除く
  #  join = "INNER JOIN system_users_groups ON (system_users.state = 'enabled' and  system_users.id = system_users_groups.user_id ) "
  #  item = System::User.new
  #  users = item.find(:all, :joins=>join, :order=> 'code', :conditions=>sql.where)
  #  users.each do |u|
  #    next if u == Core.user && Core.user.ldap != 0
  #    next unless @is_admin if u.id == Core.user.id
  #    @users_collection << u
  #  end
  #end

  def users_collection(mode=nil)
    unless mode == 'edit'
      #編集では、既に登録されているデータを利用するので初期化しない
      #updateの時は、paramsで受け取った値を設定する
      @select_recognizers = {"1"=>'',"2"=>'',"3"=>'',"4"=>'',"5"=>''}
      @select_recognizers = params[:item][:_recognizers] unless params[:item][:_recognizers].blank? unless params[:item].blank?
    end
    @users_collection = []
    sql = Condition.new
    sql.and "sql", "system_users_groups.group_id = #{Core.user_group.id}"
    join = "INNER JOIN system_users_groups ON system_users.id = system_users_groups.user_id"

    item = System::User.new
    users = item.find(:all, :joins=>join, :order=> 'code', :conditions=>sql.where)
    users.each do |u|
      next if u == Core.user && Core.user.ldap != 0
      next unless @is_admin if u.id == Core.user.id
      @users_collection << u
    end
    #承認者が選択されている状態であれば、対応するユーザレコード情報をチェックし、不足していれば追加する
    unless @select_recognizers.blank?
      for i in 1..5
        uid = @select_recognizers[i.to_s]
        users_collection_add(uid.to_i) unless uid.blank?
      end
    end
  end

  #承認者登フォームの処理が、仕様変更になり、自所属以外のユーザーも選択可能にしないといけなくなった
  #初期表示時に@users_collectionに存在しないユーザは、選択側に表示されないフォームの仕様になっていた為
  #選択されたユーザで、自所属以外のユーザを@users_collectionに追加する処理を追加する
  def users_collection_add(uid)
    flg = true
    @users_collection.each do |u|
      if uid == u.id
        flg = false if uid == u.id
      end
    end
    add_users_collection(uid) if flg
  end
  def add_users_collection(uid)
    sql = Condition.new
    sql.and "sql", "system_users_groups.user_id = #{uid}"
    join = "INNER JOIN system_users_groups ON system_users.id = system_users_groups.user_id"

    item = System::User.new
    users = item.find(:all, :joins=>join, :order=> 'code', :conditions=>sql.where)
    users.each do |u|
      next if u == Core.user && Core.user.ldap != 0
      next unless @is_admin if u.id == Core.user.id
      @users_collection << u
    end
  end

  #承認処理
  def recognized_save(item,state=2)
    case state.to_i
    when 2
      rec_mode = 1
    when 5
      rec_mode = 2
    else
      # 承認対象外
      return false
    end
    item.and :mode, rec_mode
    item.and :parent_id, params[:id].to_i
    item.and :user_id, Core.user.id
    item_r = item.find(:first)
    if item_r
      item_r.recognized_at = Time.now
      item_r.save
      flash[:notice] = '承認しました'
    end
    if search_recognize_number(item,state) == true
      return true
    end
    return false
  end

    #申請書で承認してもらう数に対して、承認が完了しているレコード数を見る
  def search_recognize_number(item,state=2)
    case state.to_i
    when 2
      rec_mode = 1
    when 5
      rec_mode = 2
    else
      # 承認対象外
      return false
    end
#    item.and :mode, rec_mode.to_i
#    item.and :parent_id, params[:id].to_i
#    item.and "sql","recognized_at IS NULL"
#    rec_users = item.find(:all)
#    count     = item.count(:all)
    rec_cond  = "mode=#{rec_mode.to_i} and parent_id=#{params[:id].to_i} and recognized_at IS NULL"
#    rec_users = item.find(:all,:conditions=>rec_cond)
    count     = item.count(:all,:conditions=>rec_cond)
#pp ['search_recognize_number',item,state,rec_mode,params[:id].to_i,rec_users,count]
    if count == 0
      return true       #認証残件数が0件の場合
    else
      return false      #認証残件数が1件以上の場合
    end
  end

end