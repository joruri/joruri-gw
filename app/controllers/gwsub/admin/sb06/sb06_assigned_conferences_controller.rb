  class Gwsub::Admin::Sb06::Sb06AssignedConferencesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwsub::Controller::Recgnize
  include Gwsub::RecognizersHelper
  include Gwsub::Admin::Sb06::Sb06AssignedConferencesHelper
  layout :switch_layout

  def switch_layout
    case params[:action]
    when 'show_print'
      "admin/template/blank"
    else
      "admin/template/portal_1column"
    end
  end

  def pre_dispatch

    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    @index_uri = "#{url_for({:action=>:index})}/"
    Page.title = "担当者名等管理"
  end

  def index
    init_params
#pp params
#    item = Gwsub::Sb06AssignedConference.new
    item = Gwsub::Sb06AssignedConferenceMember.new

    if params[:fy_id] && params[:fy_id] != '0' # 存在しない年度を指定された場合、テーブルが持つ最も古い年度で検索する
      @fy_id_exist = true
      @fy_id_find = false
      fy_id_bk = params[:fy_id]
      fy_id_item = Gwsub::Sb06AssignedConferenceMember.where("fyear_id = ?", params[:fy_id]).first
      if fy_id_item
        @fy_id_find = true
      else
        fy_id_item = Gwsub::Sb06AssignedConferenceMember.order("fyear_markjp, fyear_id").where("fyear_id = ?", params[:fy_id]).first
        if fy_id_item && fy_id_item.fyear_id
          params[:fy_id] = fy_id_item.fyear_id.to_s
          @fy_id = fy_id_item.fyear_id
        end
      end
    end
    item.search params

    if @fy_id_exist && !@fy_id_find # パラメータの値を戻す
      params[:fy_id] = fy_id_bk
    end

    item.and 'sql'," (user_id <> -1 OR official_title_name IS NOT NULL)"
    #item.and 'sql'," user_id <> -1"
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end

  def show
    rec = Gwsub::Sb06Recognizer.new
    ret = search_recognize_user(rec)
    if  ret == true
      @show_mode = nz(params[:mode],"recognize")
      params[:mode] = @show_mode
    end
    init_params
    @item = Gwsub::Sb06AssignedConference.where(:id => params[:id]).first
    return http_error(404) if @item.blank?

    #    if @item.state.to_i==2
#      @show_mode = "recognize"
#      params[:mode] = @show_mode
#    end
    member = Gwsub::Sb06AssignedConferenceMember.new
    member.conference_id  = @item.id
    member.order  @sort_keys
    @members    = member.find(:all)
    @c_cat_id   = @item.categories_id
    @fy_id      = @item.fyear_id
    @kind_id    = @item.conf_kind_id
    @c_group_id = @item.conf_group_id
    @rec_items  = Gwsub::Sb06Recognizer.new
    @l2_current = @c_cat_id
    @l3_current = @kind_id
  end


  def show_print
    rec = Gwsub::Sb06Recognizer.new
    ret = search_recognize_user(rec)
    if  ret == true
      @show_mode = nz(params[:mode],"recognize")
      params[:mode] = @show_mode
    end
    init_params
    @item = Gwsub::Sb06AssignedConference.where(:id => params[:id]).first
    return http_error(404) if @item.blank?
#    if @item.state.to_i==2
#      @show_mode = "recognize"
#      params[:mode] = @show_mode
#    end
    member = Gwsub::Sb06AssignedConferenceMember.new
    member.conference_id  = @item.id
    member.order  @sort_keys
    @members    = member.find(:all)
    @c_cat_id   = @item.categories_id
    @fy_id      = @item.fyear_id
    @kind_id    = @item.conf_kind_id
    @c_group_id = @item.conf_group_id
    @rec_items  = Gwsub::Sb06Recognizer.new
  end

  def new
    users_collection(Core.user_group.id)
    init_params

    section_item = Gwsub::Sb00ConferenceSectionManagerName.new
    section_item.and :state, 'enabled'
    section_item.and :gid, Core.user_group.id
    grp1 = section_item.find(:first)
    section_id = ""
    section_id = grp1.id unless grp1.blank?
#pp 'new',Core.user_group.id
    @l4_current = '02'
    @item = Gwsub::Sb06AssignedConference.new({
      :state              =>'1' ,
      :categories_id      => @c_cat_id ,
      :conf_kind_id       => @kind_id ,
      :fyear_id           => @fy_id ,
      :conf_group_id      => @c_group_id ,
      #:conf_at            => Gw.date_str(Core.now) ,
      :group_id           => Core.user_group.id ,
      :conf_kind_place    => "" ,
      :user_section_id    => Core.user_group.id ,
      :main_group_id      => Core.user_group.id,
      :section_manager_id => section_id,
      :admin_group_id     => Core.user_group.id
      })
    # 担当者枠
    _member_proc  = Proc.new{
      member = Gwsub::Sb06AssignedConferenceMember.new({
      :id                 => 0 ,
      :state              =>'1' ,
      :categories_id      => @c_cat_id ,
      :conf_kind_id       => @kind_id ,
      :fyear_id           => @fy_id ,
      :conf_group_id      => @c_group_id ,
      #:conf_at            => Gw.date_str(Core.now) ,
      :group_id           => Core.user_group.id ,
      :conf_kind_place    => "" ,
      :conf_item_id       => 0 ,
      #:user_id            => Core.user.id ,
      :user_id            => -1 ,
      :sort_no            => 10 ,
      :user_section_id    => Core.user_group.id ,
      :main_group_id      => Core.user_group.id,
      :section_manager_id => section_id
      })
      }
    #
    if Gwsub::Sb06AssignedConfKind.find(@kind_id).conf_kind_code=='602'
      @members  =[]
      sort_no_count = 0 #   sort_no_count は　itemが変わっても初期化しない
      conf_kind = Gwsub::Sb06AssignedConfKind.find(@kind_id)
      conf_item  = Gwsub::Sb06AssignedConfItem.new
      conf_item.select_list   = 1
      conf_item.conf_kind_id  = @kind_id
      conf_item.order "item_sort_no"
      conf_item1  = conf_item.find(:first)
      c_i_count = 0
      while c_i_count < conf_kind.conf_max_count do
        member              = _member_proc.call
        member.conf_item_id = conf_item1.id
        member.user_id      = 0 if c_i_count.to_i != 0
        member.sort_no      = member.sort_no * (sort_no_count+1)
        @members << member
#pp 'new',member,@members
          sort_no_count = sort_no_count + 1
        c_i_count = c_i_count + 1
      end
    else
      if Gwsub::Sb06AssignedConfKind.find(@kind_id).conf_kind_code=='105'
        conf_item  = Gwsub::Sb06AssignedConfItem.new
        conf_item.select_list   = 1
        conf_item.conf_kind_id  = @kind_id
        conf_item.order "item_sort_no"
        conf_items  = conf_item.find(:all)
  #pp conf_items
        @members  =[]
        @form_members  =[]
        sort_no_count = 0 #   sort_no_count は　itemが変わっても初期化しない
        conf_items.each do |c_i|
          c_i_count = 0
          while c_i_count < c_i.item_max_count do
            member              = _member_proc.call
            member.conf_item_id = c_i.id
  #          member.user_id      = 0 if c_i_count.to_i != 0
            member.user_id      = 0 if sort_no_count.to_i != 0
            member.sort_no      = member.sort_no * (sort_no_count+1)
            @members << member
            @form_members << member
  #pp 'new',member,@members
            sort_no_count = sort_no_count + 1
            c_i_count = c_i_count + 1
          end
        end
      else
        conf_item  = Gwsub::Sb06AssignedConfItem.new
        conf_item.select_list   = 1
        conf_item.conf_kind_id  = @kind_id
        conf_item.order "item_sort_no"
        conf_items  = conf_item.find(:all)
  #pp conf_items
        @members  =[]
        sort_no_count = 0 #   sort_no_count は　itemが変わっても初期化しない
        conf_items.each do |c_i|
          c_i_count = 0
          while c_i_count < c_i.item_max_count do
            member              = _member_proc.call
            member.conf_item_id = c_i.id
  #          member.user_id      = 0 if c_i_count.to_i != 0
            member.user_id      = 0 if sort_no_count.to_i != 0
            member.sort_no      = member.sort_no * (sort_no_count+1)
            @members << member
  #pp 'new',member,@members
            sort_no_count = sort_no_count + 1
            c_i_count = c_i_count + 1
          end
        end
      end
    end
  end

  def create
    users_collection(Core.user_group.id)
    init_params
    @l4_current = '02'
#pp ['create',params]
    @item = Gwsub::Sb06AssignedConference.new
    @item.state              = params[:item]['state']
    @item.categories_id      = params[:item]['categories_id']
    @item.conf_kind_id       = params[:item]['conf_kind_id']
    @item.fyear_id           = params[:item]['fyear_id']
    @item.conf_mark          = params[:item]['conf_mark']
    @item.conf_no            = params[:item]['conf_no']
    @item.conf_group_id      = params[:item]['conf_group_id']
    @item.conf_at            = params[:item]['conf_at']
    @item.group_id           = params[:item]['group_id']
    @item.section_manager_id = params[:item]['section_manager_id']
    @item.conf_kind_place    = params[:item]['conf_kind_place']
    @item._recognizers       = params[:item]['_recognizers']
    @item.admin_group_id     = params[:item]['admin_group_id']
    if @item.save
      # member 繰返し処理 index分
      kind_max_count  = Gwsub::Sb06AssignedConfKind.find(@kind_id).conf_max_count
      member_count        = 0
      member_create_count = 0
      while member_count.to_i < kind_max_count.to_i do
        # 新規でユーザー未設定はスキップ
#        if params[:item][eval("'#{member_count}'")]['user_id'].to_i==0
        if (params[:item][eval("'#{member_count}'")]['user_id'].to_i==-1 and params[:item][eval("'#{member_count}'")]['official_title_name'].blank?)
          member_count  = member_count + 1
          next
        end
        # ユーザー指定分のみ登録
        member  = Gwsub::Sb06AssignedConferenceMember.new
        # 申請書共通
        member.conference_id      = @item.id
        member.state              = @item.state
        member.categories_id      = @item.categories_id
        member.conf_kind_id       = @item.conf_kind_id
        member.fyear_id           = @item.fyear_id
        member.conf_mark          = @item.conf_mark
        member.conf_no            = @item.conf_no
        member.conf_group_id      = @item.conf_group_id
        member.conf_at            = @item.conf_at
        member.group_id           = @item.group_id
        member.conf_kind_place    = @item.conf_kind_place
        member.conf_kind_place    = "" if member.conf_kind_place == nil
        # 担当者共通
        member.conf_item_id       = params[:item][eval("'#{member_count}'")]['conf_item_id']
#        member.official_title_id  = params[:item][eval("'#{member_count}'")]['official_title_id']
        member.official_title_name  = params[:item][eval("'#{member_count}'")]['official_title_name']
        member.user_id            = params[:item][eval("'#{member_count}'")]['user_id']
        member.sort_no            = params[:item][eval("'#{member_count}'")]['sort_no']
        member.work_name          = params[:item][eval("'#{member_count}'")]['work_name']
        member.work_kind          = params[:item][eval("'#{member_count}'")]['work_kind']
        member.extension          = params[:item][eval("'#{member_count}'")]['extension']
        member.user_mail          = params[:item][eval("'#{member_count}'")]['user_mail']
        member.user_job_name      = params[:item][eval("'#{member_count}'")]['user_job_name']
        member.start_at           = params[:item][eval("'#{member_count}'")]['start_at']
        member.remarks            = params[:item][eval("'#{member_count}'")]['remarks']
        member.user_section_id    = params[:item][eval("'#{member_count}'")]['user_section_id']
        member.main_group_id      = params[:item][eval("'#{member_count}'")]['main_group_id']
        member.main_group_id      = 0 if member.main_group_id.blank?
#pp 'create',params
#pp 'create',member
        member.save(:validate => false)
        kind_105_id  = Gwsub::Sb06AssignedConfKind.where(:id => member.conf_kind_id).first
        if kind_105_id.conf_kind_code=='105'
          # 兼務チェックは検診等も登録
          if member.remarks == '1'
              conf_item_10502_id  = Gwsub::Sb06AssignedConfItem.find(:first ,:conditions=>"item_sort_no=10502 and select_list=1")
              member2  = Gwsub::Sb06AssignedConferenceMember.new
              # 申請書共通
              member2.conference_id      = member.conference_id
              member2.state              = member.state
              member2.categories_id      = member.categories_id
              member2.conf_kind_id       = member.conf_kind_id
              member2.fyear_id           = member.fyear_id
              member2.conf_mark          = member.conf_mark
              member2.conf_no            = member.conf_no
              member2.conf_group_id      = member.conf_group_id
              member2.conf_at            = member.conf_at
              member2.group_id           = member.group_id
              member2.conf_kind_place    = member.conf_kind_place
              member2.conf_kind_place    = "" if member.conf_kind_place==nil
              # 担当者共通
              member2.conf_item_id        = conf_item_10502_id.id
              member2.official_title_name = params[:item][eval("'#{member_count}'")]['official_title_name']
              member2.user_id             = params[:item][eval("'#{member_count}'")]['user_id']
              member2.sort_no             = params[:item][eval("'#{member_count}'")]['sort_no']
              member2.work_name           = params[:item][eval("'#{member_count}'")]['work_name']
              member2.work_kind           = params[:item][eval("'#{member_count}'")]['work_kind']
              member2.extension           = params[:item][eval("'#{member_count}'")]['extension']
              member2.user_mail           = params[:item][eval("'#{member_count}'")]['user_mail']
              member2.user_job_name       = params[:item][eval("'#{member_count}'")]['user_job_name']
              member2.start_at            = params[:item][eval("'#{member_count}'")]['start_at']
              member2.remarks             = params[:item][eval("'#{member_count}'")]['remarks']
              member2.user_section_id     = params[:item][eval("'#{member_count}'")]['user_section_id']
              member2.main_group_id       = params[:item][eval("'#{member_count}'")]['main_group_id']
              member2.main_group_id       = 0 if member2.main_group_id.blank?
              member2.save(:validate => false)
          end
        end
        member_create_count =member_create_count + 1
        member_count  = member_count + 1
      end
      # 登録ユーザーが０名の時、強制的に１名を作成
      if member_create_count==0
        member_count=0
        member  = Gwsub::Sb06AssignedConferenceMember.new
        # 申請書共通
        member.conference_id      = @item.id
        member.state              = @item.state
        member.categories_id      = @item.categories_id
        member.conf_kind_id       = @item.conf_kind_id
        member.fyear_id           = @item.fyear_id
        member.conf_mark          = @item.conf_mark
        member.conf_no            = @item.conf_no
        member.conf_group_id      = @item.conf_group_id
        member.conf_at            = @item.conf_at
        member.group_id           = @item.group_id
        member.conf_kind_place    = @item.conf_kind_place
        # 担当者共通
        member.conf_item_id       = params[:item][eval("'#{member_count}'")]['conf_item_id']
#        member.official_title_id  = params[:item][eval("'#{member_count}'")]['official_title_id']
        member.official_title_name  = params[:item][eval("'#{member_count}'")]['official_title_name']
        member.user_id            = 0
        member.sort_no            = params[:item][eval("'#{member_count}'")]['sort_no']
        member.work_name          = params[:item][eval("'#{member_count}'")]['work_name']
        member.work_kind          = params[:item][eval("'#{member_count}'")]['work_kind']
        member.extension          = params[:item][eval("'#{member_count}'")]['extension']
        member.user_mail          = params[:item][eval("'#{member_count}'")]['user_mail']
        member.user_job_name      = params[:item][eval("'#{member_count}'")]['user_job_name']
        member.start_at           = params[:item][eval("'#{member_count}'")]['start_at']
        member.remarks            = params[:item][eval("'#{member_count}'")]['remarks']
        member.user_section_id    = params[:item][eval("'#{member_count}'")]['user_section_id']
        member.main_group_id      = params[:item][eval("'#{member_count}'")]['main_group_id']
        member.main_group_id      = 0 if member.main_group_id.blank?
        member.save(:validate => false)
      end
    else
      # エラー時の戻り先は、new
      # 担当者枠
      _member_proc  = Proc.new{
        member = Gwsub::Sb06AssignedConferenceMember.new({
        :id                 => 0 ,
        :state              =>'1' ,
        :categories_id      => @c_cat_id ,
        :conf_kind_id       => @kind_id ,
        :fyear_id           => @fy_id ,
        :conf_group_id      => @c_group_id ,
        :conf_at            => Gw.date_str(Core.now) ,
        :group_id           => Core.user_group.id ,
        :conf_kind_place    => "" ,
        :conf_item_id       => 0 ,
        #:user_id            => Core.user.id ,
        :user_id            => -1 ,
        :sort_no            => 10 ,
        :user_section_id    => Core.user_group.id,
        :main_group_id      => Core.user_group.id
        })
        }
      #
      if Gwsub::Sb06AssignedConfKind.find(@kind_id).conf_kind_code=='602'
        @members  =[]
        sort_no_count = 0 #   sort_no_count は　itemが変わっても初期化しない
        conf_kind = Gwsub::Sb06AssignedConfKind.find(@kind_id)
        conf_item  = Gwsub::Sb06AssignedConfItem.new
        conf_item.select_list   = 1
        conf_item.conf_kind_id  = @kind_id
        conf_item.order "item_sort_no"
        conf_item1  = conf_item.find(:first)
        c_i_count = 0
        while c_i_count < conf_kind.conf_max_count do
          member              = _member_proc.call
          member.conf_item_id = conf_item1.id
          member.user_id      = 0 if c_i_count.to_i != 0
          member.sort_no      = member.sort_no * (sort_no_count+1)
          @members << member
  #pp 'new',member,@members
            sort_no_count = sort_no_count + 1
          c_i_count = c_i_count + 1
        end
      else
        if Gwsub::Sb06AssignedConfKind.find(@kind_id).conf_kind_code=='105'
          conf_item  = Gwsub::Sb06AssignedConfItem.new
          conf_item.select_list   = 1
          conf_item.conf_kind_id  = @kind_id
          conf_item.order "item_sort_no"
          conf_items  = conf_item.find(:all)
    #pp conf_items
          @members  =[]
          @form_members  =[]
          sort_no_count = 0 #   sort_no_count は　itemが変わっても初期化しない
          conf_items.each do |c_i|
            c_i_count = 0
            while c_i_count < c_i.item_max_count do
              member              = _member_proc.call
              member.conf_item_id = c_i.id
    #          member.user_id      = 0 if c_i_count.to_i != 0
              member.user_id      = 0 if sort_no_count.to_i != 0
              member.sort_no      = member.sort_no * (sort_no_count+1)
              # ユーザー入力がなければ初期値
              if (params[:item][eval("'#{c_i_count}'")]['user_id'].to_i==-1 and params[:item][eval("'#{c_i_count}'")]['official_title_name'].blank?)
#                member_count  = member_count + 1
                @members << member
                @form_members << member
                sort_no_count = sort_no_count + 1
                c_i_count = c_i_count + 1
                next
              end
              # ユーザー入力分をパラメータから上書き
              member.official_title_name = params[:item][eval("'#{c_i_count}'")]['official_title_name']
              member.user_id             = params[:item][eval("'#{c_i_count}'")]['user_id']
              member.sort_no             = params[:item][eval("'#{c_i_count}'")]['sort_no']
              member.work_name           = params[:item][eval("'#{c_i_count}'")]['work_name']
              member.work_kind           = params[:item][eval("'#{c_i_count}'")]['work_kind']
              member.extension           = params[:item][eval("'#{c_i_count}'")]['extension']
              member.user_mail           = params[:item][eval("'#{c_i_count}'")]['user_mail']
              member.user_job_name       = params[:item][eval("'#{c_i_count}'")]['user_job_name']
              member.start_at            = params[:item][eval("'#{c_i_count}'")]['start_at']
              member.remarks             = params[:item][eval("'#{c_i_count}'")]['remarks']
              member.user_section_id     = params[:item][eval("'#{c_i_count}'")]['user_section_id']
              member.main_group_id       = params[:item][eval("'#{c_i_count}'")]['main_group_id']
              member.main_group_id       = 0 if member.main_group_id.blank?
              @members << member
              @form_members << member
    #pp 'new',member,@members
              sort_no_count = sort_no_count + 1
              c_i_count = c_i_count + 1
            end
          end
        else
          conf_item  = Gwsub::Sb06AssignedConfItem.new
          conf_item.select_list   = 1
          conf_item.conf_kind_id  = @kind_id
          conf_item.order "item_sort_no"
          conf_items  = conf_item.find(:all)
    #pp conf_items
          @members  =[]
          sort_no_count = 0 #   sort_no_count は　itemが変わっても初期化しない
          conf_items.each do |c_i|
            c_i_count = 0
            while c_i_count < c_i.item_max_count do
              member              = _member_proc.call
              member.conf_item_id = c_i.id
    #          member.user_id      = 0 if c_i_count.to_i != 0
              member.user_id      = 0 if sort_no_count.to_i != 0
              member.sort_no      = member.sort_no * (sort_no_count+1)
              @members << member
    #pp 'new',member,@members
              sort_no_count = sort_no_count + 1
              c_i_count = c_i_count + 1
            end
          end
        end
      end
      respond_to do |format|
        format.html { render :action => "new" }
      end
      return
    end
    # 担当者データ作成後に、直接提出の時は管理者に通知
    if @item.state.to_i==4
      send_admin2(@item , @fy_id)
    end
    # 一覧表示へ
    flash[:notice]  = "登録処理が完了しました。"
    param = "?pre_fy_id=#{@fy_id}&fy_id=#{@fy_id}&pre_c_cat_id=#{@c_cat_id}&c_cat_id=#{@c_cat_id}&kind_id=#{@kind_id}"
    location = url_for({:action => :index})+param
    redirect_to location
#    _update(@item,:success_redirect_uri=>location)
  end

  def edit
    users_collection(Core.user_group.id)
    init_params
    @item = Gwsub::Sb06AssignedConference.where(:id => params[:id]).first
    return http_error(404) if @item.blank?

    return redirect_to(url_for({:action => :edit_docno, :id => params[:id]})) if @item.state == "3"

    @c_cat_id   = @item.categories_id
    @fy_id      = @item.fyear_id
    @kind_id    = @item.conf_kind_id
    @c_group_id = @item.conf_group_id
    @l2_current = @c_cat_id
    @l3_current = @kind_id
    @rec_items = Gwsub::Sb06Recognizer.new

    # 担当者枠
    _member_proc  = Proc.new{
      member = Gwsub::Sb06AssignedConferenceMember.new({
      :id                 => 0,
      :state              =>'1' ,
      :categories_id      => @c_cat_id ,
      :conf_kind_id       => @kind_id ,
      :fyear_id           => @fy_id ,
      :conf_group_id      => @c_group_id ,
      #:conf_at            => Gw.date_str(Core.now) ,
      :group_id           => Core.user_group.id ,
      :conf_kind_place    => "" ,
      :conf_item_id       => 0 ,
      #:user_id            => Core.user.id ,
      :user_id            => '' ,
      :sort_no            => 10 ,
      :user_section_id    => Core.user_group.id,
      :main_group_id      => Core.user_group.id
      })
      }
    #
    if Gwsub::Sb06AssignedConfKind.find(@kind_id).conf_kind_code=='602'
      @members  =[]
      sort_no_count = 0 #   sort_no_count は　itemが変わっても初期化しない
      conf_kind = Gwsub::Sb06AssignedConfKind.find(@kind_id)
      conf_item  = Gwsub::Sb06AssignedConfItem.new
      conf_item.select_list   = 1
      conf_item.conf_kind_id  = @kind_id
      conf_item.order "item_sort_no"
      conf_item1  = conf_item.find(:first)
      member = Gwsub::Sb06AssignedConferenceMember.new
      member.conference_id  = @item.id
      member.order  "sort_no"
      members  =   member.find(:all)
      members.each do |m|
#        # 共済兼務で作成したデータはスキップ
#        next if m.conf_item_sort_no==10502 and m.remarks.to_i==1
        @members << m
        sort_no_count = m.sort_no
      end
      count_init= members.size.to_i - 1
      c_i_count = members.size.to_i
      while c_i_count < conf_kind.conf_max_count do
        member   = _member_proc.call
        member.conf_item_id = conf_item1.id
        member.user_id      = 0 if c_i_count.to_i != count_init.to_i
        member.sort_no      = sort_no_count.to_i + 10
        @members << member
        sort_no_count = member.sort_no
        c_i_count = c_i_count + 1
      end
    else
      if Gwsub::Sb06AssignedConfKind.find(@kind_id).conf_kind_code=='105'
        sort_no_count = 0 #   sort_no_count は　itemが変わっても初期化しない
        conf_item  = Gwsub::Sb06AssignedConfItem.new
        conf_item.select_list   = 1
        conf_item.conf_kind_id  = @kind_id
        conf_item.order "item_sort_no"
        conf_items  = conf_item.find(:all)
        @members  =[]
        @form_members  =[]
        conf_item_count = 0
        conf_items.each do |c_i|
          conf_item_count = conf_item_count + c_i.item_max_count
          member = Gwsub::Sb06AssignedConferenceMember.new
          member.conference_id  = @item.id
          member.conf_item_id   = c_i.id
          member.order  "conf_item_sort_no,sort_no"
          members  =   member.find(:all)
          members.each do |m|
            unless (m.conf_item_sort_no==10502 and m.remarks.to_i==1)
              # 共済・検診で、兼務で作成したユーザーはフォームに表示しない
              @form_members << m
            end
            @members << m
            sort_no_count = m.sort_no if sort_no_count < m.sort_no
          end
          count_init= @form_members.size.to_i - 1
          c_i_count = @form_members.size.to_i
          while c_i_count < conf_item_count do
            member   = _member_proc.call
            member.conf_item_id = c_i.id
            member.user_id  = 0 if c_i_count.to_i != count_init.to_i
            member.sort_no  = sort_no_count + 10
            @form_members << member
            c_i_count = c_i_count + 1
            sort_no_count = member.sort_no
          end
        end
      else
        sort_no_count = 0 #   sort_no_count は　itemが変わっても初期化しない
        conf_item  = Gwsub::Sb06AssignedConfItem.new
        conf_item.select_list   = 1
        conf_item.conf_kind_id  = @kind_id
        conf_item.order "item_sort_no"
        conf_items  = conf_item.find(:all)
        @members  =[]
        conf_items.each do |c_i|
          member = Gwsub::Sb06AssignedConferenceMember.new
          member.conference_id  = @item.id
          member.conf_item_id   = c_i.id
          member.order  "conf_item_sort_no,sort_no"
          members  =   member.find(:all)
          members.each do |m|
            @members << m
            sort_no_count = m.sort_no if sort_no_count < m.sort_no
          end
          count_init= members.size.to_i - 1
          c_i_count = members.size.to_i
          while c_i_count < c_i.item_max_count do
            member   = _member_proc.call
            member.conf_item_id = c_i.id
            member.user_id  = 0 if c_i_count.to_i != count_init.to_i
            member.sort_no  = sort_no_count + 10
            @members << member
            c_i_count = c_i_count + 1
            sort_no_count = member.sort_no
          end
        end
      end
    end
  end

  def update
    users_collection(Core.user_group.id)
    init_params
# pp ['update',params]
    @item = Gwsub::Sb06AssignedConference.where(:id => params[:id]).first
    return http_error(404) if @item.blank?

    @c_cat_id   = @item.categories_id
    @fy_id      = @item.fyear_id
    @kind_id    = @item.conf_kind_id
    @c_group_id = @item.conf_group_id
    @l2_current = @c_cat_id
    @l3_current = @kind_id
    @item.state              = params[:item]['state']
    @item.categories_id      = params[:item]['categories_id']
    @item.conf_kind_id       = params[:item]['conf_kind_id']
    @item.fyear_id           = params[:item]['fyear_id']
    @item.conf_mark          = params[:item]['conf_mark']
    @item.conf_no            = params[:item]['conf_no']
    @item.conf_group_id      = params[:item]['conf_group_id']
    @item.conf_at            = params[:item]['conf_at']
    @item.group_id           = params[:item]['group_id']
    @item.section_manager_id = params[:item]['section_manager_id']
    @item.conf_kind_place    = params[:item]['conf_kind_place']
    @item.admin_group_id     = params[:item]['admin_group_id']
#    @item._recognizers     = params[:item]['_recognizers']
    if @item.save
      # 共済等とりまとめでは、各種検診担当も洗い替え
      kind_105_id  = Gwsub::Sb06AssignedConfKind.where(:id => @item.conf_kind_id).first
      if kind_105_id.conf_kind_code=='105'
#        Gwsub::Sb06AssignedConferenceMember.delete_all("conference_id=#{@item.id} and conf_item_sort_no=10502")
        # 兼務で自動作成したデータは削除
        Gwsub::Sb06AssignedConferenceMember.delete_all("conference_id=#{@item.id} and conf_item_sort_no=10502 and remarks='1'")
      end
      # member 繰返し処理 index分
      kind_max_count  = Gwsub::Sb06AssignedConfKind.find(@kind_id).conf_max_count
      member_count    = 0
      member_updated_count = 0
      while member_count.to_i < kind_max_count.to_i do
        # id がないデータは、追加
#pp member_count,params[:item][eval("'#{member_count}'")]
        if params[:item][eval("'#{member_count}'")]['id'].to_i==0
          # ユーザー指定がなければスキップ
          #if params[:item][eval("'#{member_count}'")]['user_id'].to_i==0
          if params[:item][eval("'#{member_count}'")]['user_id'].to_i== -1
            member_count = member_count + 1
            next
          else
            member  = Gwsub::Sb06AssignedConferenceMember.new
          end
        else
        # id があるデータは、編集
          #if params[:item][eval("'#{member_count}'")]['user_id'].to_i==0
          if (params[:item][eval("'#{member_count}'")]['user_id'].to_i== -1 and params[:item][eval("'#{member_count}'")]['official_title_name'].blank?)
            # ユーザー指定がなければ削除
            member  = Gwsub::Sb06AssignedConferenceMember.where(:id => params[:item][eval("'#{member_count}'")]['id']).first
            unless member.blank?
              member.destroy
            end
            member_count = member_count + 1
            next
          else
            member  = Gwsub::Sb06AssignedConferenceMember.where(:id => params[:item][eval("'#{member_count}'")]['id']).first
            # 共済等とりまとめでは、検診ユーザー登録を削除しているので、IDで読めない場合はスキップ
            if member.blank?
              member_count = member_count + 1
              next
            end
          end
        end
        # 申請書共通
        member.conference_id      = @item.id
        member.state              = @item.state
        member.categories_id      = @item.categories_id
        member.conf_kind_id       = @item.conf_kind_id
        member.fyear_id           = @item.fyear_id
        member.conf_mark          = @item.conf_mark
        member.conf_no            = @item.conf_no
        member.conf_group_id      = @item.conf_group_id
        member.conf_at            = @item.conf_at
        member.group_id           = @item.group_id
        member.conf_kind_place    = @item.conf_kind_place
        # 担当者共通
        member.conf_item_id       = params[:item][eval("'#{member_count}'")]['conf_item_id']
#        member.official_title_id  = params[:item][eval("'#{member_count}'")]['official_title_id']
        member.official_title_name  = params[:item][eval("'#{member_count}'")]['official_title_name']
        member.user_id            = params[:item][eval("'#{member_count}'")]['user_id']
        member.sort_no            = params[:item][eval("'#{member_count}'")]['sort_no']
        member.work_name          = params[:item][eval("'#{member_count}'")]['work_name']
        member.work_kind          = params[:item][eval("'#{member_count}'")]['work_kind']
        member.extension          = params[:item][eval("'#{member_count}'")]['extension']
        member.user_mail          = params[:item][eval("'#{member_count}'")]['user_mail']
        member.user_job_name      = params[:item][eval("'#{member_count}'")]['user_job_name']
        member.start_at           = params[:item][eval("'#{member_count}'")]['start_at']
        member.remarks            = params[:item][eval("'#{member_count}'")]['remarks']
        member.user_section_id    = params[:item][eval("'#{member_count}'")]['user_section_id']
        member.main_group_id      = params[:item][eval("'#{member_count}'")]['main_group_id']
        member.main_group_id      = 0 if member.main_group_id.blank?
#pp 'create',params
#pp 'update',member
        member.save(:validate => false)
        # 兼務チェックは検診等も登録
        if member.conf_item_sort_no==10501
          if member.remarks == '1'
              conf_item_10502_id  = Gwsub::Sb06AssignedConfItem.find(:first ,:conditions=>"item_sort_no=10502 and select_list=1")
              member2  = Gwsub::Sb06AssignedConferenceMember.new
              # 申請書共通
              member2.conference_id      = member.conference_id
              member2.state              = member.state
              member2.categories_id      = member.categories_id
              member2.conf_kind_id       = member.conf_kind_id
              member2.fyear_id           = member.fyear_id
              member2.conf_mark          = member.conf_mark
              member2.conf_no            = member.conf_no
              member2.conf_group_id      = member.conf_group_id
              member2.conf_at            = member.conf_at
              member2.group_id           = member.group_id
              member2.conf_kind_place    = member.conf_kind_place
              member2.conf_kind_place    = "" if member.conf_kind_place==nil
              # 担当者共通
              member2.conf_item_id        = conf_item_10502_id.id
              member2.official_title_name = params[:item][eval("'#{member_count}'")]['official_title_name']
              member2.user_id             = params[:item][eval("'#{member_count}'")]['user_id']
              member2.sort_no             = params[:item][eval("'#{member_count}'")]['sort_no']
              member2.work_name           = params[:item][eval("'#{member_count}'")]['work_name']
              member2.work_kind           = params[:item][eval("'#{member_count}'")]['work_kind']
              member2.extension           = params[:item][eval("'#{member_count}'")]['extension']
              member2.user_mail           = params[:item][eval("'#{member_count}'")]['user_mail']
              member2.user_job_name       = params[:item][eval("'#{member_count}'")]['user_job_name']
              member2.start_at            = params[:item][eval("'#{member_count}'")]['start_at']
              member2.remarks             = params[:item][eval("'#{member_count}'")]['remarks']
              member2.user_section_id     = params[:item][eval("'#{member_count}'")]['user_section_id']
              member2.main_group_id       = params[:item][eval("'#{member_count}'")]['main_group_id']
              member2.save(:validate => false)
          end
        end
        member_count  = member_count + 1
        member_updated_count =member_updated_count + 1
      end
      # 更新ユーザーが０名の時、強制的に１名を作成
      if member_updated_count==0
        member_count=0
        member  = Gwsub::Sb06AssignedConferenceMember.new
        # 申請書共通
        member.conference_id      = @item.id
        member.state              = @item.state
        member.categories_id      = @item.categories_id
        member.conf_kind_id       = @item.conf_kind_id
        member.fyear_id           = @item.fyear_id
        member.conf_mark          = @item.conf_mark
        member.conf_no            = @item.conf_no
        member.conf_group_id      = @item.conf_group_id
        member.conf_at            = @item.conf_at
        member.group_id           = @item.group_id
        member.conf_kind_place    = @item.conf_kind_place
        # 担当者共通
        member.conf_item_id       = params[:item][eval("'#{member_count}'")]['conf_item_id']
#        member.official_title_id  = params[:item][eval("'#{member_count}'")]['official_title_id']
        member.official_title_name  = params[:item][eval("'#{member_count}'")]['official_title_name']
        member.user_id            = 0
        member.sort_no            = params[:item][eval("'#{member_count}'")]['sort_no']
        member.work_name          = params[:item][eval("'#{member_count}'")]['work_name']
        member.work_kind          = params[:item][eval("'#{member_count}'")]['work_kind']
        member.extension          = params[:item][eval("'#{member_count}'")]['extension']
        member.user_mail          = params[:item][eval("'#{member_count}'")]['user_mail']
        member.user_job_name      = params[:item][eval("'#{member_count}'")]['user_job_name']
        member.start_at           = params[:item][eval("'#{member_count}'")]['start_at']
        member.remarks            = params[:item][eval("'#{member_count}'")]['remarks']
        member.user_section_id    = params[:item][eval("'#{member_count}'")]['user_section_id']
        member.save(:validate => false)
      end
    else
      #エラー処理
      # エラー時の戻り先は、edit
      # 担当者枠
      _member_proc  = Proc.new{
        member = Gwsub::Sb06AssignedConferenceMember.new({
        :id                 => 0,
        :state              =>'1' ,
        :categories_id      => @c_cat_id ,
        :conf_kind_id       => @kind_id ,
        :fyear_id           => @fy_id ,
        :conf_group_id      => @c_group_id ,
        :conf_at            => Gw.date_str(Core.now) ,
        :group_id           => Core.user_group.id ,
        :conf_kind_place    => "" ,
        :conf_item_id       => 0 ,
        #:user_id            => Core.user.id ,
        :user_id            => '' ,
        :sort_no            => 10 ,
        :user_section_id    => Core.user_group.id,
        :main_group_id      => Core.user_group.id
        })
        }
      #
      if Gwsub::Sb06AssignedConfKind.find(@kind_id).conf_kind_code=='602'
        @members  =[]
        sort_no_count = 0 #   sort_no_count は　itemが変わっても初期化しない
        conf_kind = Gwsub::Sb06AssignedConfKind.find(@kind_id)
        conf_item  = Gwsub::Sb06AssignedConfItem.new
        conf_item.select_list   = 1
        conf_item.conf_kind_id  = @kind_id
        conf_item.order "item_sort_no"
        conf_item1  = conf_item.find(:first)
        member = Gwsub::Sb06AssignedConferenceMember.new
        member.conference_id  = @item.id
        member.order  "sort_no"
        members  =   member.find(:all)
        members.each do |m|
          @members << m
          sort_no_count = m.sort_no
        end
        count_init= members.size.to_i - 1
        c_i_count = members.size.to_i
        while c_i_count < conf_kind.conf_max_count do
          member   = _member_proc.call
          member.conf_item_id = conf_item1.id
          member.user_id      = 0 if c_i_count.to_i != count_init.to_i
          member.sort_no      = sort_no_count.to_i + 10
          @members << member
          sort_no_count = member.sort_no
          c_i_count = c_i_count + 1
        end
      else
        if Gwsub::Sb06AssignedConfKind.find(@kind_id).conf_kind_code=='105'
          sort_no_count = 0 #   sort_no_count は　itemが変わっても初期化しない
          conf_item  = Gwsub::Sb06AssignedConfItem.new
          conf_item.select_list   = 1
          conf_item.conf_kind_id  = @kind_id
          conf_item.order "item_sort_no"
          conf_items  = conf_item.find(:all)
          @members  =[]
          @form_members  =[]
          conf_item_count = 0
          conf_items.each do |c_i|
            conf_item_count = conf_item_count + c_i.item_max_count
            member = Gwsub::Sb06AssignedConferenceMember.new
            member.conference_id  = @item.id
            member.conf_item_id   = c_i.id
            member.order  "conf_item_sort_no,sort_no"
            members  =   member.find(:all)
            members.each do |m|
              unless (m.conf_item_sort_no==10502 and m.remarks.to_i==1)
                # 共済・検診で、兼務で作成したユーザーはフォームに表示しない
                @form_members << m
              end
              @members << m
              sort_no_count = m.sort_no if sort_no_count < m.sort_no
            end
            count_init= @form_members.size.to_i - 1
            c_i_count = @form_members.size.to_i
            while c_i_count < conf_item_count do
              member   = _member_proc.call
              member.conf_item_id = c_i.id
              member.user_id  = 0 if c_i_count.to_i != count_init.to_i
              member.sort_no  = sort_no_count + 10
              @form_members << member
              c_i_count = c_i_count + 1
              sort_no_count = member.sort_no
            end
          end
        else
          sort_no_count = 0 #   sort_no_count は　itemが変わっても初期化しない
          conf_item  = Gwsub::Sb06AssignedConfItem.new
          conf_item.select_list   = 1
          conf_item.conf_kind_id  = @kind_id
          conf_item.order "item_sort_no"
          conf_items  = conf_item.find(:all)
          @members  =[]
          conf_items.each do |c_i|
            member = Gwsub::Sb06AssignedConferenceMember.new
            member.conference_id  = @item.id
            member.conf_item_id   = c_i.id
            member.order  "conf_item_sort_no,sort_no"
            members  =   member.find(:all)
            members.each do |m|
              @members << m
              sort_no_count = m.sort_no if sort_no_count < m.sort_no
            end
            count_init= members.size.to_i - 1
            c_i_count = members.size.to_i
            while c_i_count < c_i.item_max_count do
              member   = _member_proc.call
              member.conf_item_id = c_i.id
              member.user_id  = 0 if c_i_count.to_i != count_init.to_i
              member.sort_no  = sort_no_count + 10
             @members << member
             c_i_count = c_i_count + 1
              sort_no_count = member.sort_no
            end
          end
        end
      end
      respond_to do |format|
        format.html { render :action => "edit" }
      end
      return
    end
    # 担当者データ作成後に、直接提出の時は管理者に通知
    if @item.state.to_i==4
      send_admin2(@item , @fy_id)
    end
    # 詳細表示へ
    flash[:notice]  = "更新処理が完了しました。"
    location = url_for({:action => :show, :id => params[:id]})
    redirect_to location
#    _update(@item,:success_redirect_uri=>location)
  end

  def draft_on
    item = Gwsub::Sb06AssignedConference.find(params[:id])
    item_member  = Gwsub::Sb06AssignedConferenceMember.new
    item_member.conference_id = item.id
    item_members  = item_member.find(:all)
    item.state  = '1'
    item.save(:validate => false)
    item_members.each do |member|
      member.state  = '1'
      member.save(:validate => false)
    end
    # 承認者がいる場合はクリア
    Gwsub::Sb06Recognizer.delete_all(["parent_id = ?",params[:id]])
    # 処理後は詳細画面に戻す
    flash[:notice]  = "下書きに戻しました。"
    location = url_for({:action => :show, :id => params[:id]})
    redirect_to location
  end
  def check_on
    item = Gwsub::Sb06AssignedConference.find(params[:id])
    item_member  = Gwsub::Sb06AssignedConferenceMember.new
    item_member.conference_id = item.id
    item_members  = item_member.find(:all)
    item.state  = '5'
    item.save(:validate => false)
    item_members.each do |member|
      member.state  = '5'
      member.save(:validate => false)
    end
    # 処理後は詳細画面に戻す
    flash[:notice]  = "確認済に更新しました。"
    location = url_for({:action => :show, :id => params[:id]})
    redirect_to location
  end
  def check_off
    item = Gwsub::Sb06AssignedConference.find(params[:id])
    item_member  = Gwsub::Sb06AssignedConferenceMember.new
    item_member.conference_id = item.id
    item_members  = item_member.find(:all)
    item.state  = '4'
    item.save(:validate => false)
    item_members.each do |member|
      member.state  = '4'
      member.save(:validate => false)
    end
    # 処理後は詳細画面に戻す
    flash[:notice]  = "提出済に戻しました。"
    location = url_for({:action => :show, :id => params[:id]})
    redirect_to location
  end

  def destroy
    @item = Gwsub::Sb06AssignedConference.new.find(params[:id])

    @c_cat_id   = @item.categories_id
    @fy_id      = @item.fyear_id
    @kind_id    = @item.conf_kind_id
    @c_group_id = @item.conf_group_id
    @l2_current = @c_cat_id
    @l3_current = @kind_id
    @rec_items = Gwsub::Sb06Recognizer.new
    param = "?pre_fy_id=#{@fy_id}&fy_id=#{@fy_id}&pre_c_cat_id=#{@c_cat_id}&c_cat_id=#{@c_cat_id}&kind_id=#{@kind_id}"
    location = url_for({:action => :index}) + param
    options={
      :success_redirect_uri=>location
    }
    _destroy(@item,options)
  end

  def csvput
    init_params
    @l3_current = 'csv'

    return if params[:item].nil?
    par_item = params[:item]
    nkf_options = case par_item[:nkf]
        when 'utf8'
          '-w'
        when 'sjis'
          '-s'
        end
    case par_item[:csv]
    when 'put'
      if par_item[:fyed_id].blank?
        flash[:notice] = "年度を指定してください。"
        return
      end
      c_name = Gwsub::Sb06AssignedConfCategory.find(par_item[:c_cat_id].to_i).cat_name
      kind_name = Gwsub::Sb06AssignedConfKind.find(par_item[:kind_id].to_i).conf_kind_name
      kind_code = Gwsub::Sb06AssignedConfKind.find(par_item[:kind_id].to_i).conf_kind_code
      filename = "#{c_name}_#{kind_name}_#{par_item[:nkf]}.csv"

      item = Gwsub::Sb06AssignedConferenceMember.new
      item.and 'sql',"fyear_id       = #{par_item[:fyed_id].to_i}"   unless par_item[:fyed_id].to_i == 0
      item.and 'sql',"conf_kind_id   = #{par_item[:kind_id]}"
      item.and 'sql',"categories_id  = #{par_item[:c_cat_id]}"
      item.and 'sql',"user_id <> -1"

      # 出力項目指定
      case kind_code.to_i
      when 105
        # 共済互助会通知システムとりまとめ担当者、
        select  = "group_name_display,conf_item_title,user_section_name,user_name,main_group_name,state"
        # 出力データ抽出
        item.order " conf_item_sort_no ,state, user_section_sort_no , sort_no "
        item = item.find(:all,:select=>select)
        if item.blank?
          flash[:notice] = "出力データはありませんでした。"
          return
        else
          #select_jp = select_to_jp(select,'gwsub_sb06_assigned_conferences')
          select_jp = "申請所属,種別,所属,氏名,取りまとめ所属,状態"
#pp select,item
          file = Gw::Script::Tool.ar_to_csv(item, :cols=>select,:header=>false)
          select_jp << "\n"
          select_jp << file
          send_data NKF::nkf(nkf_options,select_jp), :filename => filename
          return
        end
      when 301
        # 自衛消防地区隊員
        item.order " group_code ,conference_id , conf_item_sort_no  "
        select = "group_name_display,conf_item_title,official_title_name,user_name,conf_at,conf_mark,conf_no"
        # 出力データ抽出
        item = item.find(:all,:select=>select )

        if item.blank?
          flash[:notice] = "出力データはありませんでした。"
          return
        else
          #select_jp = select_to_jp(select,'gwsub_sb06_assigned_conferences')
          select_jp = "申請所属,区分・名称,職名,氏名,申請日,記号,番号"
          file = Gw::Script::Tool.ar_to_csv(item, :cols=>select,:header=>false)
          select_jp << "\n"
          select_jp << file
          send_data NKF::nkf(nkf_options,select_jp), :filename => filename
          return
        end
      when 302
        # 火気取締責任者等
        item.order " group_code ,conference_id ,conf_kind_place,conf_item_sort_no  "
        select = "group_name_display,conf_kind_place,conf_item_title,official_title_name,user_name,conf_at,conf_mark,conf_no"
        # 出力データ抽出
        item = item.find(:all,:select=>select )

        if item.blank?
          flash[:notice] = "出力データはありませんでした。"
          return
        else
          #select_jp = select_to_jp(select,'gwsub_sb06_assigned_conferences')
          select_jp = "申請所属,場所,区分･名称,職名,氏名,申請日,記号,番号"
          file = Gw::Script::Tool.ar_to_csv(item, :cols=>select,:header=>false)
          select_jp << "\n"
          select_jp << file
          send_data NKF::nkf(nkf_options,select_jp), :filename => filename
          return
        end
      when 401
        # 情報化推進員・OA活用担当者
        item.order " group_code ,conference_id ,conf_item_sort_no  "
        select = "group_name_display,conf_item_title,official_title_name,user_name,user_mail,conf_at,conf_mark,conf_no"
        # 出力データ抽出
        items = item.find(:all,:select=>select)

        if items.blank?
          flash[:notice] = "出力データはありませんでした。"
          return
        else
          #select_jp = select_to_jp(select,'gwsub_sb06_assigned_conferences')
          select_jp = "申請所属,区分･名称,職名,氏名,メールアドレス,申請日,記号,番号"
pp items
          file = Gw::Script::Tool.ar_to_csv(items , :cols=>select ,:header=>false)
          select_jp << "\n"
          select_jp << file
          send_data NKF::nkf(nkf_options,select_jp), :filename => filename
          return
        end
      else
        item.order params[:id], @sort_keys
        select = "group_name_display,conf_item_title,official_title_name,user_name,conf_at,conf_mark,conf_no"
        # 出力データ抽出
        item = item.find(:all,:select=>select)

        if item.blank?
          flash[:notice] = "出力データはありませんでした。"
          return
        else
          #select_jp = select_to_jp(select,'gwsub_sb06_assigned_conferences')
          select_jp = "申請所属,区分･名称,職名,氏名,申請日,記号,番号"
          file = Gw::Script::Tool.ar_to_csv(item, :cols=>select,:header=>false)
          select_jp << "\n"
          select_jp << file
          send_data NKF::nkf(nkf_options,select_jp), :filename => filename
          return
        end
      end
    else
      index_params  = "?fy_id=#{@fy_id}&c_cat_id=#{par_item[:c_cat_id]}&kind_id=#{par_item[:kind_id]}"
      location = url_for({:action => :index})+index_params
      redirect_to location
    end
  end
  def csvup
    init_params
    return if params[:item].nil?
    par_item = params[:item]
    case par_item[:csv]
    when 'up'
#      raise ArgumentError, '入力指定が異常です。' if par_item.nil? || par_item[:nkf].nil? || par_item[par_item[:nkf]].nil?
      if par_item.nil? || par_item[:nkf].nil? || par_item[:file].nil?
        flash[:notice] = 'ファイル名を入力してください'
      else
        upload_data = par_item[:file]
        f = upload_data.read
        nkf_options = case par_item[:nkf]
        when 'utf8'
          '-w -W'
        when 'sjis'
          '-w -S'
        end
        file =  NKF::nkf(nkf_options,f)
        if file.blank?
        else
          Gwsub::Sb06AssignedConference.truncate_table
          s_to = Gw::Script::Tool.import_csv(file, "gwsub_sb06_assigned_conferences")
  #        pp s_to
        end
        location = url_for({:action => :index})
        redirect_to location
      end
    else
    end
  end
  def init_params
#pp params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb06AssignedConference.is_dev?
    @role_admin      = Gwsub::Sb06AssignedConference.is_admin?
    @u_role = @role_developer || @role_admin
    @role_editor     = Core.user_group.code

    @menu_header3 = 'sb06_assigned_conferences'
    @menu_title3  = '担当者名等管理'

    # 一覧表示選択条件を、メニュー選択と検索UIで合わせる（初期値での年度、主管所属、申請書種別「すべて」を抑止）
    # 年度
    fy_group    = "fyear_markjp"
    fy_order    = "fyear_markjp DESC , group_code ASC"
    fyear       = Gw::YearFiscalJp.get_record(Time.now)
    fy_id       = fyear.blank? ? nil : fyear.id
#    @fy_id      = nz(params[:fy_id],fy_id)
    @fy_id      = params[:fy_id]
    if @fy_id.to_i == 0 && fy_id
      @fy_id = fy_id
    end
#pp fyear,@fy_id
    # 申請書分類
    # 初期値は「すべて」
#    @c_cat_id = nz(params[:c_cat_id],0)
    # 初期値は分類先頭
    cat_1 =Gwsub::Sb06AssignedConfCategory.order("cat_sort_no").first
    if cat_1.blank?
      c_cat_id  = 0
    else
      c_cat_id  = cat_1.id
    end
    @c_cat_id = nz(params[:c_cat_id],c_cat_id)

    # 申請書種別
    # 分類変更時は、申請書種別を初期化
    if params[:pre_c_cat_id] != params[:c_cat_id]
      params.delete('kind_id')
      @kind_id == 0
    end
    conf_kind_options = {:cat_id=>@c_cat_id, :fyear_id=>@fy_id}
    conf_kinds    = Gwsub::Sb06AssignedConfKind.sb06_assign_conf_kind_id_select(conf_kind_options)
    if conf_kinds.blank?
      @kind_id      = nz(params[:kind_id],0)
    else
      kind_id       = conf_kinds[0]
      @kind_id      = nz(params[:kind_id],0)          if      @c_cat_id.to_i==0
      @kind_id      = nz(params[:kind_id],kind_id[1]) unless  @c_cat_id.to_i==0
    end
    @kind_id = get_sb06_conference_kind_id(@kind_id , conf_kinds,@fy_id.to_i)
    params[:kind_id] = @kind_id unless params[:kind_id].to_i == @kind_id.to_i
    # 申請書指定時は、分類逆引き
    if @kind_id.to_i==0
    else
      conf_kind  =  Gwsub::Sb06AssignedConfKind.find(@kind_id)
      conf_cat   = Gwsub::Sb06AssignedConfCategory.find(conf_kind.conf_cat_id)
      @c_cat_id = conf_cat.id unless conf_cat.blank?
      params[:c_cat_id] = @c_cat_id
    end

    # 申請所属
    @group_id     = nz(params[:group_id],0)
    # 一般は自所属のみ表示
#    if @u_role==true
#      @group_id     = nz(params[:group_id],0)
#    else
#      @group_id     = nz(params[:group_id],Core.user_group.id)
#    end
    # 表示行数　設定
    @limit = nz(params[:limit],30)

    # 状態選択
    @c_state=nz(params[:c_state],0)

    # 詳細表示モード (main/recognizer/view)
    @show_mode = nz(params[:mode],"main")
    params[:mode] = @show_mode

    # 説明管理　処理後の変数クリア
    @help=nil

    search_condition
    setting_sortkeys
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current = '01'
    @l2_current = @c_cat_id
    @l3_current = @kind_id
    @l4_current = '01'

    # 共通機能での表示用ヘッダ
    @piece_header = '担当者名等管理'
    return
  end
  def search_condition
    params[:limit]        = nz(params[:limit]     , @limit)
    params[:c_state]      = nz(params[:c_state]   , @c_state)
    params[:fy_id]        = nz(params[:fy_id]     , @fy_id)
    params[:c_cat_id]     = nz(params[:c_cat_id]  , @c_cat_id)
    params[:kind_id]      = nz(params[:kind_id]   , @kind_id)
    params[:group_id]     = nz(params[:group_id]  , @group_id)

    qsa = ['limit', 's_keyword','c_state','fy_id','c_cat_id','kind_id','group_id' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def setting_sortkeys
#    @sort_keys = nz(params[:sort_keys], 'fyear_id DESC , conf_kind_id ASC , group_id ASC , conf_item_sort_no')
#    @sort_keys = nz(params[:sort_keys], 'fyear_markjp DESC , conf_kind_sort_no ASC , group_id ASC , conf_kind_place , sort_no')
    # Members 用ソートキー
#    @sort_keys = nz(params[:sort_keys], 'state,fyear_markjp DESC , cat_sort_no , conf_kind_sort_no , conf_group_code , conf_kind_place ,conference_id, conf_item_sort_no , sort_no ')
    @sort_keys = nz(params[:sort_keys], 'state,fyear_markjp DESC , cat_sort_no , conf_kind_sort_no , group_code , conf_kind_place ,conference_id,conf_item_sort_no, sort_no ')
  end

  def user_fields
    users = []
    users << ['[指定なし]',-1] if params[:sp] == 'y'
    users += System::User.get_user_select(params[:g_id], nil, ldap: 1)
    render text: view_context.options_for_select(users), layout: false
  end

    #--------------承認関係----------------
  #承認処理
  def recognized
    init_params
    item = Gwsub::Sb06AssignedConference.find(params[:id])
    item.attributes = params[:item]
    @item = Gwsub::Sb06Recognizer.new
    if recognized_save(@item) == true #trueならば、担当者にリマインダー通知
       member = Gwsub::Sb06AssignedConferenceMember.new
       member.conference_id  = item.id
       members    = member.find(:all)
       members.each do|m|
           m.state = '3'
           m.save(:validate => false)
           end
      item.state ='3'
      item.save(:validate => false)
      item.rec_comp
    end

    location = url_for({:action => :show, :id => :params[:id]})
    redirect_to location
  end

  #却下処理
  def rejected
    init_params
    @item = Gwsub::Sb06AssignedConference.find(params[:id])
#    @item.attributes = params[:item]
    @item.state = '1'
    member  = Gwsub::Sb06AssignedConferenceMember.new
    member.conference_id  = @item.id
    members =member.find(:all)
    members.each do |m|
      m.state = '1'
      m.save(:validate => false)
    end
    @item.save
    Gwsub::Sb06Recognizer.delete_all(["parent_id = ?",params[:id]])
    flash[:notice] = '却下しました'
    @item.rec_rejected  #担当者にリマインダー却下通知
    # 一覧表示用パラメーター作成
    @c_cat_id   = @item.categories_id
    @fy_id      = @item.fyear_id
    @kind_id    = @item.conf_kind_id
    @c_group_id = @item.conf_group_id
    @rec_items = Gwsub::Sb06Recognizer.new
    param = "?pre_fy_id=#{@fy_id}&fy_id=#{@fy_id}&pre_c_cat_id=#{@c_cat_id}&c_cat_id=#{@c_cat_id}&kind_id=#{@kind_id}"
    location = url_for({:action => :index})+param
    redirect_to location
  end

  #リマインダー通知：担当者→承認者
  #　Gwsub::Sb06AssignedConference
  #  after_save :save_recognizers
  # 参照のこと。

  #リマインダー通知：担当者→管理者
  def send_admin2(item,fy_id)
    # 承認なしで提出の場合
#    item = Gwsub::Sb06AssignedConference.find(params[:id])
    kind = Gwsub::Sb06AssignedConfCategory.find(item.categories_id)
    kind_no = kind.cat_code
    memo_send = Gwsub::Sb00ConferenceManager.new
    memo_send.controler   = "sb06_assigned_conferences_#{kind_no}"
    memo_send.fyear_id    = fy_id
    memo_send.send_state  = '1'
    memo_sender = memo_send.find(:all)
#pp ['send_admin2' , item,fy_id,memo_send , memo_sender]
    options={:fr_user => item.updated_user_id,
              :is_system => 1}
    memo_sender.each do |m|
      index_location  = url_for({:action => :index})
      Gw.add_memo(m.user_id.to_s, m.memo_str, "<a href='#{index_location}#{item.id}'>申請内容を確認してください。</a>",options)
    end
  end
  #リマインダー通知：承認完了→管理者
  def send_admin
    # 全承認完了後の自動送信
    init_params
    @item = Gwsub::Sb06AssignedConference.find(params[:id])
      #リマインダー通知のみ。
      kind_no = select_kind
      memo_send = Gwsub::Sb00ConferenceManager.new
      memo_send.and :controler , "sb06_assigned_conferences_#{kind_no}"
      memo_send.and :fyear_id ,  @fy_id
      memo_send.and :send_state ,  '1'
      memo_sender = memo_send.find(:all)
      options={:fr_user => @item.created_user_id,
              :is_system => 1}
      memo_sender.each do |m|
      index_location  = url_for({:action => :index})
      Gw.add_memo(m.user_id.to_s, m.memo_str, "<a href='#{index_location}#{@item.id}'>申請内容を確認してください。</a>",options)
      end
  end

  def select_kind
    item = Gwsub::Sb06AssignedConference.find(params[:id])
    kind = Gwsub::Sb06AssignedConfCategory.find(item.categories_id)
    return kind.cat_code
  end

  def edit_docno
    init_params
    @item = Gwsub::Sb06AssignedConference.find(params[:id])
    member = Gwsub::Sb06AssignedConferenceMember.new
    member.conference_id  = @item.id
    member.order  @sort_keys
    @members    = member.find(:all)
    @c_cat_id   = @item.categories_id
    @fy_id      = @item.fyear_id
    @kind_id    = @item.conf_kind_id
    @c_group_id = @item.conf_group_id
    @rec_items  = Gwsub::Sb06Recognizer.new
    @l2_current = @c_cat_id
    @l3_current = @kind_id
  end

  def udpate_docno
    users_collection(Core.user_group.id)
    init_params
    @item = Gwsub::Sb06AssignedConference.new.find(params[:id])
    @item.attributes = params[:item]
    member = Gwsub::Sb06AssignedConferenceMember.new
    member.conference_id  = @item.id
    member.order  @sort_keys
    @members    = member.find(:all)
    @item.state = '4'
    location = url_for({:action => :show, :id => @item.id})
    form_no = @item.c_kind.conf_form_no
    member = Gwsub::Sb06AssignedConferenceMember.new
    member.conference_id  = @item.id
    members    = member.find(:all)
    case form_no
    when "301" ,"302","303","401","602"
      members.each do|m|
        m.state = '4'
        m.conf_mark = @item.conf_mark
        m.conf_no = @item.conf_no
        m.save
      end
    else
      members.each do|m|
        m.state = '4'
        m.save
      end
    end
    if @item.save
      location = url_for({:action => :show, :id => params[:id]})
      send_admin
      redirect_to location
    else
        members.each do|m|
        m.state = '3'
        m.save
        end
      @item.state = '3'
      render :action => :edit_docno
    end
  end

  def manager_name_field
    groups = Gwsub::Sb00ConferenceSectionManagerName.get_g_names(params[:t_id].to_i)
    render text: view_context.options_for_select(groups), layout: false
  end
end
