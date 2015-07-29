# -*- encoding: utf-8 -*-
class Gwsub::Admin::Sb01::Sb01TrainingScheduleConditionsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::SortKey
  include Gwbbs::Model::DbnameAlias
  include Gwboard::Controller::Authorize

  # 研修　施設予約　条件
  layout "admin/template/sb01_training"

  def pre_dispatch
    Page.title = "研修申込・受付"
    @public_uri = "/gwsub/sb01/sb01_training_schedule_conditions"
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    init_params
    @item1 = Gwsub::Sb01Training.find(@t_id)
    item = Gwsub::Sb01TrainingScheduleCondition.new
    item.search params
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end
  def show
    init_params
    @item = Gwsub::Sb01TrainingScheduleCondition.find(params[:id])
    @item1 = Gwsub::Sb01Training.find(@item.training_id)
  end

  def new
    init_params
    @l2_current         ='02'
    params[:l2_c]      = '02'
    @item1 = Gwsub::Sb01Training.find(@t_id)
    @item = Gwsub::Sb01TrainingScheduleCondition.new
    @item.training_id   = @t_id
    @item.title         = @item.training_rel.title
    @item.from_at       = Gw.date_str(Time.now)
    @item.from_start    = "14"
    @item.from_start_min= "00"
    @item.from_end      = "16"
    @item.from_end_min  = "00"
    @item.member_id     = Site.user.id
    @item.repeat_flg    = '1'
    @item.state         = '2'
    @item.prop_kind     = '9'
    @item.prop_name     = ''
  end

  def create
    init_params
    new_item  = Gwsub::Sb01TrainingScheduleCondition.set_f(params[:item])
    @item     = Gwsub::Sb01TrainingScheduleCondition.new(new_item)
    @item1    = Gwsub::Sb01Training.find(params[:item]['training_id'])
    after_process = Proc.new{
      make_schedule
      update_bbs_doc}
    location = "/gwsub/sb01/sb01_training_plans/#{params[:item]['training_id']}"
    options = {
      :after_process => after_process,
      :success_redirect_uri=>location
    }
    _create(@item,options)
  end

  def edit
    init_params
    @item = Gwsub::Sb01TrainingScheduleCondition.find(params[:id])
    @item1 = Gwsub::Sb01Training.find(@item.training_id)
  end

  def update
    init_params
    @item = Gwsub::Sb01TrainingScheduleCondition.find(params[:id])
    new_item = Gwsub::Sb01TrainingScheduleCondition.set_f(params[:item])
    @item.attributes = new_item
    @item1 = Gwsub::Sb01Training.find(@item.training_id)
    after_process = Proc.new{
      from_st = "#{@item.from_start}:#{@item.from_start_min}"
      from_ed = "#{@item.from_end}:#{@item.from_end_min}"
      update_schedule(from_st, from_ed,@item.prop_name,@item.members_max)
      update_members_schedule(from_st, from_ed,@item.prop_name)
      }
    location = "#{@public_uri}/#{@item.id}?t_id=#{@item.training_id}"
    options = {
      :after_process => after_process,
      :success_redirect_uri=>location
    }
    _update(@item,options)
  end

  def update_schedule(from_st, from_ed,prop, m_max)
    t_skd = Gwsub::Sb01TrainingSchedule.find(:all, :conditions => "condition_id = #{@item.id}")
    unless t_skd.blank?
      t_skd.each do |s|
        skd = Gw::Schedule.find_by_id(s.schedule_id)
        unless skd.blank?
          skd_st = skd.st_at.strftime('%Y-%m-%d ')
          skd_st += from_st
          skd_ed = skd.ed_at.strftime('%Y-%m-%d ')
          skd_ed += from_ed
          skd.st_at = skd_st
          skd.ed_at = skd_ed
          skd.place = prop
          skd.save
        end
          s.from_start  = skd_st
          s.from_end    = skd_ed
          s.prop_name   = prop
          s.members_max = m_max
          if s.state == '3'
            if s.members_max > s.members_current
              s.state = '2'
            end
          end
          s.save
      end
    end
  end

  def update_members_schedule(from_st, from_ed,prop)
    skd_m = Gwsub::Sb01TrainingScheduleMember.find(:all, :conditions => "condition_id = #{@item.id}")
    unless skd_m.blank?
      skd_m.each do |s|
        skd = Gw::Schedule.find_by_id(s.schedule_id)
        unless skd.blank?
          skd_st = skd.st_at.strftime('%Y-%m-%d ')
          skd_st += from_st
          skd_ed = skd.ed_at.strftime('%Y-%m-%d ')
          skd_ed += from_ed
          skd.st_at = skd_st
          skd.ed_at = skd_ed
          skd.place = prop
          skd.save
        end
      end
    end
  end

  def destroy
    init_params
    @item = Gwsub::Sb01TrainingScheduleCondition.find(params[:id])
    location = "/gwsub/sb01/sb01_training_plans/#{@item.training_id}"
    after_process = Proc.new{
        destroy_schedule
        destroy_members_shcedule
      }
    options = {
      :success_redirect_uri=>location,
      :after_process       =>after_process
    }
    _destroy(@item,options)
  end

  def destroy_schedule
    t_skd = Gwsub::Sb01TrainingSchedule.find(:all, :conditions => "condition_id = #{@item.id}")
    unless t_skd.blank?
      t_skd.each do |t|
        skd = Gw::Schedule.find_by_id(t.schedule_id)
        skd.destroy unless skd.blank?
        t.destroy
      end
    end
  end
  def destroy_members_shcedule
    skd_m = Gwsub::Sb01TrainingScheduleMember.find(:all, :conditions => "condition_id = #{@item.id}")
    unless skd_m.blank?
      skd_m.each do |m|
        skd = Gw::Schedule.find_by_id(m.schedule_id)
        skd.destroy unless skd.blank?
        m.destroy
      end
    end
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb01Training.is_dev?(Site.user.id)
    @role_admin      = Gwsub::Sb01Training.is_admin?(Site.user.id)
    @u_role = @role_developer || @role_admin

    # 研修id
    @t_id_top = Gwsub::Sb01Training.find(:first,:order=>"fyear_markjp DESC")
    @t_id = nz(params[:t_id],@t_id_top.id)
    # 予約条件id
    @c_id = nz(params[:c_id],0)
    # 表示行数　設定
    @limits = nz(params[:limit],30)
    # メニュー見出し
    @menu_title = "予約条件設定"

    @bbs_link_title  = '別ウィンドウ・別タブで案内記事を開きます'

    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    @l1_current=nz(params[:l1_c],'02')
    @l2_current=nz(params[:l2_c],'01')
  end

  def search_condition
    params[:l1_c]     = nz(params[:l1_c],@l1_current)
    params[:l2_c]     = nz(params[:l2_c],@l2_current)
    params[:t_id]     = nz(params[:t_id], @t_id)
    params[:c_id]     = nz(params[:c_id], @c_id)
    params[:limit]    = nz(params[:limit], @limits)

    qsa = ['limit' , 's_keyword' , 'title','t_id','c_id' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def sortkeys_setting
    @sort_keys = nz(params[:sort_keys], 'updated_at DESC , title' )
  end

  def make_schedule
    repeats = Gwsub::Sb01TrainingScheduleCondition.repeat_dates(@item)
    if repeats.blank?
      # 対象日がなければ、そのまま詳細表示へ
      #location = "#{Site.current_node.public_uri}#{@c_id}?t_id=#{@t_id}"
      #redirect_to location
      return
    end

    #repeat_idを決定
    if @item.repeat_flg == '2'
      skd_repeat = Gw::ScheduleRepeat.new({
        :st_date_at  => @item.from_at,
        :ed_date_at  => @item.to_at,
        :st_time_at  => '2010-04-01 '+ @item.from_start+ ':' + @item.from_start_min,
        :ed_time_at  => '2010-04-01 '+ @item.from_end+ ':' + @item.from_end_min,
        :class_id    => @item.repeat_class_id,
        :weekday_ids => @item.repeat_weekday
      })
      if skd_repeat.save
        repeat_id = skd_repeat.id
      else
        repeat_id = nil
      end
    else
      repeat_id = nil
    end

    repeats.each do |s|
      skd = Gw::Schedule.new({
          :title_category_id  => 300 ,
          :title              => s[0] ,
          :place_category_id  => nil ,
          :is_public          => 1 ,
          :is_pr              => nil ,
          :memo               => nil ,
          :inquire_to         => @item.training_rel.member_tel ,
          :place              => @item.prop_name,
          :repeat_id          => repeat_id,
          :st_at              => s[1] ,
          :ed_at              => s[2] ,
          :creator_uid        => @item.training_rel.member_id ,
          :creator_ucode      => @item.training_rel.member_code ,
          :creator_uname      => @item.training_rel.member_name ,
          :creator_gid        => @item.training_rel.group_id ,
          :creator_gcode      => @item.training_rel.group_code ,
          :creator_gname      => @item.training_rel.group_name ,
          :updater_uid        => @item.training_rel.member_id ,
          :updater_ucode      => @item.training_rel.member_code ,
          :updater_uname      => @item.training_rel.member_name ,
          :updater_gid        => @item.training_rel.group_id ,
          :updater_gcode      => @item.training_rel.group_code ,
          :updater_gname      => @item.training_rel.group_name ,
          :owner_uid          => @item.training_rel.member_id ,
          :owner_ucode        => @item.training_rel.member_code ,
          :owner_uname        => @item.training_rel.member_name ,
          :owner_gid          => @item.training_rel.group_id ,
          :owner_gcode        => @item.training_rel.group_code ,
          :owner_gname        => @item.training_rel.group_name
        })
        skd.save!
        # メンバー
        skd_user = Gw::ScheduleUser.new({
          :schedule_id      =>  skd.id ,
          :class_id         =>  1 ,
          :uid              =>  s[4],
          :st_at              => s[1],
          :ed_at              => s[2]
          })
        skd_user.save!
        # 研修スケジュール
        skd_training = Gwsub::Sb01TrainingSchedule.new({
          :training_id      =>  @item.training_id.to_i ,
          :condition_id     =>  @item.id.to_i ,
          :schedule_id      =>  skd.id.to_i ,
          :members_max      =>  s[5].to_i ,
          :members_current  =>  0,
          :state            =>  @item.training_rel.state,
          :from_start       =>  s[1] ,
          :from_end         =>  s[2],
          :prop_name        =>  @item.prop_name
        })
        skd_training.save!
      end
  end
  
  def update_bbs_doc
    init_params
    training = Gwsub::Sb01Training.find(@item.training_id)
    ts_condition = Gwsub::Sb01TrainingScheduleCondition.find(:all, :conditions => ['training_id = ?', @item.training_id])
    url = training.bbs_url
    if url.blank?
      return
    end
    title_id  = url.scan(/title_id=([\d]+)/)
    title_id  = title_id[0][0]
    doc_id    = url.scan(/docs\/([\d]+)/)
    doc_id    = doc_id[0][0]
    if doc_id.blank?
      return
    end
    if ts_condition.blank?
      return
    end
    #掲示板掲載終了日
    expiry_date = []
    expiry = Time.now.strftime("%Y-%m-%d")
    ts_condition.each do |ts|
      if ts.repeat_flg == '1'
        expiry_date << ts.from_at.strftime("%Y-%m-%d")
      else
        expiry_date << ts.to_at.strftime("%Y-%m-%d")
      end
    end
    if expiry_date.size == 1
        expiry = expiry_date[0]
    else
      expiry_date.each do |e|
        if expiry > e
          next
        else
          expiry = e
        end
      end
    end
    expiry += ' 23:59:59'
    @title = Gwbbs::Control.find_by_id(title_id)
    return if @title.blank?
    unless (@title.dbname.blank? && @title.state == 'closed')
      bbs = gwbbs_db_alias(Gwbbs::Doc)
      @bbs = bbs.find_by_id(training.bbs_doc_id)
      if @bbs.blank?
        Gwbbs::Doc.remove_connection
        return
      end
      @bbs.expiry_date = expiry
      @bbs.save
      Gwbbs::Doc.remove_connection
    end
  end
end