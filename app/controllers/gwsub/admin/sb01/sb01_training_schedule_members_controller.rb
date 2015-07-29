# -*- encoding: utf-8 -*-
class Gwsub::Admin::Sb01::Sb01TrainingScheduleMembersController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  layout "admin/template/sb01_training"
  
  def pre_dispatch
    Page.title = "研修申込・受付"
    @public_uri = "/gwsub/sb01/sb01_training_schedule_members"
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    init_params
    @item1 = Gwsub::Sb01Training.find(@t_id)
    @prop  = Gwsub::Sb01TrainingScheduleProp.find(@p_id)
    item   = Gwsub::Sb01TrainingScheduleMember.new
    item.search params
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end

  def show
    init_params
    @item1 = Gwsub::Sb01Training.find(@t_id)
    @ts  = Gwsub::Sb01TrainingSchedule.find(@p_id)
    @item  = Gwsub::Sb01TrainingScheduleMember.find(params[:id])
  end

  def new
    init_params
    @item1 = Gwsub::Sb01Training.find(@t_id)
    @ts    = Gwsub::Sb01TrainingSchedule.find(@p_id)
    @item  = Gwsub::Sb01TrainingScheduleMember.new
    today = Time.now
    if @ts.state == '3'
      flash[:notice] = "研修日のステータスが「締切」のため、申込できません。"
      location = "/gwsub/sb01/sb01_training_entries/#{@item1.id}"
      return redirect_to location
    elsif @ts.from_start < today
      flash[:notice] = "開催日を過ぎているため、申込できません。"
      location = "/gwsub/sb01/sb01_training_entries/#{@item1.id}"
      return redirect_to location
    elsif @ts.members_max == @ts.members_current
      flash[:notice] = "定員に達しているため、申込できません。"
      location = "/gwsub/sb01/sb01_training_entries/#{@item1.id}"
      return redirect_to location
    end
    @item.training_schedule_id  = @p_id
    @item.training_user_id      = Site.user.id
    @item.training_group_id     = Site.user_group.id
    @item.entry_user_id         = Site.user.id
    @item.entry_group_id        = Site.user_group.id
  end

  def create
    init_params
    @item1 = Gwsub::Sb01Training.find(@t_id)
    @ts    = Gwsub::Sb01TrainingSchedule.find(@p_id)
    @item  = Gwsub::Sb01TrainingScheduleMember.new(params[:item])
    @item.training_id = @item1.id
    @item.condition_id = @ts.condition_id
    location = "/gwsub/sb01/sb01_training_schedules/#{@p_id}?t_id=#{@item1.id}&t_menu=#{@top_menu}"
    options = {
      :success_redirect_uri=>location,
      :after_process=>Proc.new{
        skd = Gw::Schedule.new({
          :title_category_id  => 300 ,
          :title              => @item1.title ,
          :place_category_id  => nil ,
          :is_public          => 1 ,
          :is_pr              => nil ,
          :memo               => nil ,
          :inquire_to         => @item.training_user_tel ,
          :place              => @ts.prop_name,
          :repeat_id          => nil,
          :st_at              => @ts.from_start,
          :ed_at              => @ts.from_end,
          :creator_uid        => @item.entry_user_id ,
          :creator_ucode      => @item.user_rel2.code ,
          :creator_uname      => @item.user_rel2.name ,
          :creator_gid        => @item.entry_group_id ,
          :creator_gcode      => @item.group_rel2.code ,
          :creator_gname      => @item.group_rel2.name ,
          :updater_uid        => @item.entry_user_id ,
          :updater_ucode      => @item.user_rel2.code ,
          :updater_uname      => @item.user_rel2.name ,
          :updater_gid        => @item.entry_group_id ,
          :updater_gcode      => @item.group_rel2.code ,
          :updater_gname      => @item.group_rel2.name ,
          :owner_uid          => @item.entry_user_id ,
          :owner_ucode        => @item.user_rel2.code ,
          :owner_uname        => @item.user_rel2.name ,
          :owner_gid          => @item.entry_group_id ,
          :owner_gcode        => @item.group_rel2.code ,
          :owner_gname        => @item.group_rel2.name ,
        })
        skd.save
        # メンバー
        skd_user = Gw::ScheduleUser.new({
          :schedule_id     =>  skd.id ,
          :class_id        =>  1 ,
          :uid             =>  @item.training_user_id ,
          :st_at           => @ts.from_start,
          :ed_at           => @ts.from_end
          })
        skd_user.save!
        @skd_m = Gwsub::Sb01TrainingScheduleMember.find_by_id(@item.id)
        unless @skd_m.blank?
          @skd_m.schedule_id = skd.id
          @skd_m.save
        end
        t_prop = Gwsub::Sb01TrainingSchedule.find(@p_id)
        t_prop.members_current = t_prop.members_current.to_i + 1
        if t_prop.members_current.to_i >= t_prop.members_max.to_i
          t_prop.state = '3'
        end
        t_prop.save
      }
    }
    _create(@item,options)
  end

  def destroy
    init_params
    @item1 = Gwsub::Sb01Training.find(@t_id)
    @ts    = Gwsub::Sb01TrainingSchedule.find(@p_id)
    @item = Gwsub::Sb01TrainingScheduleMember.find(params[:id])
    location = "/gwsub/sb01/sb01_training_schedules/#{@p_id}?t_id=#{@item1.id}&t_menu=#{@top_menu}"
    options = {
      :success_redirect_uri=>location,
      :after_process=>Proc.new{
        skd = Gw::Schedule.find_by_id(@item.schedule_id)
        skd.destroy unless skd.blank?
        t_prop = Gwsub::Sb01TrainingSchedule.find(@p_id)
        t_prop.members_current = t_prop.members_current.to_i - 1
        if t_prop.members_current.to_i < t_prop.members_max.to_i
          # 申し込み取り消しで定員われのときは受付中に戻す
          t_prop.state = '2'
        end
        t_prop.save
      }
    }
    _destroy(@item,options)
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb01Training.is_dev?(Site.user.id)
    @role_admin      = Gwsub::Sb01Training.is_admin?(Site.user.id)
    @u_role = @role_developer || @role_admin

    # 表示行数　設定
    @limits = nz(params[:limit],30)
    # 研修id
    @t_id_top = Gwsub::Sb01Training.find(:first,:order=>"fyear_markjp DESC")
    @t_id = nz(params[:t_id],@t_id_top.id)
    # 開催日id
    prop_cond = "gwsub_sb01_training_schedules.training_id=#{@t_id}"
    prop_order = "gwsub_sb01_training_schedule_conditions.from_at"
    @p_id_top = Gwsub::Sb01TrainingSchedule.find(:first,:include=>[:condition],:conditions=>prop_cond,:order=>prop_order)
    @p_id = nz(params[:p_id],@p_id_top.id)
    # 経路
    @top_menu = nz(params[:t_menu],'entries')
    case @top_menu
    when 'plans'
      @menu_title = "企画・設定"
    else
      @menu_title = "検索・申込"
    end

    @bbs_link_title  = '別ウィンドウ・別タブで案内記事を開きます'

    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    case @top_menu
    when 'plans'
      @l1_current=nz(params[:l1_c],'02')
    when 'entries'
      @l1_current=nz(params[:l1_c],'01')
    else
      @l1_current=nil
    end
    @l2_current=nz(params[:l1_c],'02')
#pp params
  end

  def search_condition
    params[:t_id]     =nz(params[:t_id],@t_id)
    params[:p_id]     =nz(params[:p_id],@p_id)
    params[:t_menu]   =nz(params[:t_menu],@top_menu)
    params[:limit]    = nz(params[:limit], @limits)

    qsa = ['limit' , 's_keyword' , 't_id' , 'p_id'  ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def sortkeys_setting
    @sort_keys = nz(params[:sort_keys], 'from_start' )
#    @sort_keys = nz(params[:sort_keys], 'fyear_markjp DESC , categories ASC , bbs_url ASC' )
  end

  def user_fields
#pp ['user_fields',params]
    users = System::User.get_user_select(params[:g_id])
    html_select = "<option value=''>[指定なし]</option>"
    users.each do |value , key|
      html_select << "<option value='#{key}'>#{value}</option>"
    end
#pp ['user_fields',params,users,html_select]
    respond_to do |format|
      format.csv { render :text => html_select ,:layout=>false ,:locals=>{:f=>@item} }
    end
  end
end
