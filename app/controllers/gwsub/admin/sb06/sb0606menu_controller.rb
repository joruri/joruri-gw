class Gwsub::Admin::Sb06::Sb0606menuController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch

    return redirect_to(url_for(action: :index)) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "管理対象一覧"
    init_params
    return error_auth unless @u_role == true
  end

  #設定テーブルメンテナンス：対象テーブルの一覧をCms::Nodeから取得
  #ディレクトリ登録時に、このメニューと同じ階層にコントローラーを登録すること
  def index

  end

  def set_fyear
    @current_fyear = Gw::YearFiscalJp.get_record(Time.now)
    @prev_fyear = Gw::YearFiscalJp.get_record(@current_fyear.start_at.yesterday) unless @current_fyear.blank?
  end


  def new
    set_fyear
    location = url_for({:action => :index})
    @copy_fyear_id = 0
    @copy_fyear_id  = @prev_fyear.id unless @prev_fyear.blank?

    # コピー元取得
    item = Gwsub::Sb06AssignedConfGroup.new
    item.and :fyear_id , @copy_fyear_id
    item.order "group_code"
    items = item.find(:all)

    # コピー先年度取得
    if @copy_fyear_id.to_i==0
      current_fyear = Gw::YearFiscalJp.get_record(Time.now)
    else
      current_fyear =Gw::YearFiscalJp.find(@copy_fyear_id)
    end
    next_fyear = Gw::YearFiscalJp.get_next_year_record(current_fyear.start_at)
    unless next_fyear.blank?

      # コピー先データ取得
      item = Gwsub::Sb06AssignedConfGroup.new
      item.and :fyear_id , next_fyear.id
      item.order "group_code"
      items_del = item.find(:all)
      unless items_del.blank?
        Gwsub::Sb06AssignedConfGroup.destroy_all("fyear_id = #{next_fyear.id}")
  #        flash[:notice] = "コピー済です。"
  #        redirect_to location
  #        return
      end
      Gwsub::Sb06AssignedConfGroup.transaction do
        # コピー
        begin
          items.each do |item1|
            n_group_id = get_next_group_id(item1.group_id, next_fyear)
            next_group = System::GroupHistory.where(:id => n_group_id).first
            item_new = Gwsub::Sb06AssignedConfGroup.new
            item_new.fyear_id      = next_fyear.id
            item_new.fyear_markjp  = next_fyear.markjp
            item_new.group_id      = next_group.id
            item_new.group_code    = next_group.code
            item_new.group_name    = next_group.name
            item_new.categories_id = item1.categories_id
            item_new.cat_sort_no   = item1.cat_sort_no
            item_new.cat_code      = item1.cat_code
            item_new.cat_name      = item1.cat_name
            item_new.save(:validate => false)
          end
        rescue
          next
        end
      end
    end

    # コピー先年度取得
    if @copy_fyear_id.to_i==0
      current_fyear = Gw::YearFiscalJp.get_record(Time.now)
    else
      current_fyear =Gw::YearFiscalJp.find(@copy_fyear_id)
    end
    next_fyear = Gw::YearFiscalJp.get_next_year_record(current_fyear.start_at)

    unless next_fyear.blank?

      # コピー元取得
      conf_item = Gwsub::Sb06AssignedConfKind.new
      conf_item.and :fyear_id , @copy_fyear_id
      conf_item.order "conf_kind_code"
      conf_items = conf_item.find(:all)

      #コピー先取得
      conf_item_del = Gwsub::Sb06AssignedConfKind.new
      conf_item_del.and :fyear_id , next_fyear.id
      conf_item_del.order "conf_kind_code"
      conf_items_del = conf_item_del.find(:all)

      unless conf_items_del.blank?
        Gwsub::Sb06AssignedConfKind.destroy_all("fyear_id = #{next_fyear.id}")
      end
      Gwsub::Sb06AssignedConfKind.transaction do
        # コピー
        begin
          conf_items.each do |item1|

            item_new = Gwsub::Sb06AssignedConfKind.new
            item_new.fyear_id          = next_fyear.id
            item_new.fyear_markjp      = next_fyear.markjp
            item_new.conf_cat_id       = item1.conf_cat_id
            item_new.conf_kind_code    = item1.conf_kind_code
            item_new.conf_kind_name    = item1.conf_kind_name
            item_new.conf_kind_sort_no = item1.conf_kind_sort_no
            item_new.conf_menu_name    = item1.conf_menu_name
            item_new.conf_to_name      = item1.conf_to_name
            item_new.conf_title        = item1.conf_title
            item_new.conf_form_no      = item1.conf_form_no
            item_new.conf_max_count    = item1.conf_max_count
            item_new.select_list       = item1.select_list
            item_new.conf_body         = item1.conf_body
            item_new.save(:validate => false)

            next_conf_id = item_new.id
            old_conf_items = Gwsub::Sb06AssignedConfItem.where(:conf_kind_id =>item1.id)
            old_conf_items.each do |item2|
              conf_item_new                 = Gwsub::Sb06AssignedConfItem.new
              conf_item_new.fyear_id        = next_fyear.id
              conf_item_new.fyear_markjp    = next_fyear.markjp
              conf_item_new.conf_kind_id    = next_conf_id
              conf_item_new.item_sort_no    = item2.item_sort_no
              conf_item_new.item_title      = item2.item_title
              conf_item_new.item_max_count  = item2.item_max_count
              conf_item_new.select_list     = item2.select_list
              conf_item_new.save(:validate => false)
            end unless old_conf_items.blank?
          end
        rescue => e
          next
        end
      end
    end
    flash[:notice] = "マスターデータの次年度分を登録しました。"
    redirect_to location
    return
  end

  def get_next_group_id(group_id, next_fyear)
    old_group = System::GroupHistory.where(:id => group_id).first
    group_next = System::GroupNext.where(:old_group_id => group_id)
    if group_next.blank?
      parent_move = System::GroupNext.where(:old_group_id => old_group.parent_id)
      return group_id if parent_move.blank?
      u_group = System::GroupHistory.where("code = ? and start_at >= ?",old_group.code, next_fyear.start_at.strftime("%Y-%m-%d %H:%M")).order("start_at desc").first

      return u_group.id unless u_group.blank?
      return group_id
    end
    next_ids = []
    group_next.each do |n|
      next_ids << n.group_update_id
    end
    group_updates = System::GroupUpdate.find(next_ids)
    return group_id if group_updates.blank?
    group_updates.each do |u|
      update_fyear = Gw::YearFiscalJp.get_record(u.start_at)
      next if update_fyear.blank?
      if update_fyear.id == next_fyear.id
        u_group = System::GroupHistory.where("code = ? and start_at >= ?",u.code, u.start_at.strftime("%Y-%m-%d %H:%M")).order("start_at desc").first

        return u_group.id unless u_group.blank?
      end
    end
    return group_id
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb06AssignedConference.is_dev?
    @role_admin      = Gwsub::Sb06AssignedConference.is_admin?
    @u_role = @role_developer || @role_admin
    @role_editor     = Core.user_group.code

    @menu_header3 = 'sb0606menu'
    @menu_title3  = 'コード管理'
    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current='04'
    @l2_current='01'

    # 共通機能での表示用ヘッダ
    @piece_header = '担当者名等管理'
    return
  end
  def search_condition
  end
  def sortkeys_setting
    @sort_keys = nz(params[:sort_keys], 'title ASC')
  end

end
