# -*- encoding: utf-8 -*-
class Gwsub::Admin::Sb04::Sb04SeatingListsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::SortKey
  include Gwbbs::Model::DbnameAlias
  include Gwboard::Controller::Authorize

  layout "admin/template/portal_1column"

  def initialize_scaffold
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
    @page_title = "事務分掌表・座席表掲示板"
  end

  def index
    init_params
    item = Gwsub::Sb04SeatingList.new #.readable
    item.search params
    item.page   params[:page], params[:limit]
    item.order  params[:id], @sort_keys
    @items = item.find(:all)
    _index @items
  end
  def show
    init_params
    @item = Gwsub::Sb04SeatingList.find_by_id(params[:id])
    return redirect_to http_error(404) if @item.blank?

    if params[:docs]=='create'
      rtn = create_bbs_docs
      case rtn
      when '1'
        flash[:notice] = '掲示板が指定されていません。'
      when '2'
        flash[:notice] = '所属名の取得に失敗しました。'
      when '3'
        flash[:notice] = '記事一括登録に失敗しました。'
      else
        flash[:notice] = '記事一括登録が完了しました。'
      end
    end
    if params[:docs]=='geturl'
      rtn = geturl_bbs_docs
      case rtn
      when '1'
        flash[:notice] = '掲示板が指定されていません。'
      when '2'
        flash[:notice] = '記事一覧取得に失敗しました。'
      when '3'
        flash[:notice] = '記事一括取得に失敗しました。'
      else
        flash[:notice] = '記事一括取得が完了しました。'
      end
    end
#    @item = Gwsub::Sb04SeatingList.find(params[:id])
  end

  def new
    init_params
    @l3_current = '03'
    @item = Gwsub::Sb04SeatingList.new
  end
  def create
    init_params
    @l3_current = '03'

    new_item = Gwsub::Sb04SeatingList.set_f(params[:item])

    @item = Gwsub::Sb04SeatingList.new(new_item)

    options={:location=>"/gwsub/sb04/04/sb04_seating_lists?#{@qs}"}
    _create(@item,options)
  end

  def edit
    init_params
    @item = Gwsub::Sb04SeatingList.find_by_id(params[:id])
    return redirect_to http_error(404) if @item.blank?
  end
  def update
    init_params
    @item = Gwsub::Sb04SeatingList.find_by_id(params[:id])
    return redirect_to http_error(404) if @item.blank?

    new_item = Gwsub::Sb04SeatingList.set_f(params[:item])
    @item.attributes = new_item

    options={:location=>"/gwsub/sb04/04/sb04_seating_lists/#{@item.id}?#{@qs}"}
    _update(@item,options)
  end

  def destroy
    init_params
    @item = Gwsub::Sb04SeatingList.find(params[:id])
    return redirect_to http_error(404) if @item.blank?

    options={:location=>"/gwsub/sb04/04/sb04_seating_lists?#{@qs}"}
    _destroy(@item,options)
  end

  def init_params
    # ユーザー権限設定
    @role_developer  = Gwsub::Sb04stafflist.is_dev?(Core.user.id)
    @role_admin      = Gwsub::Sb04stafflist.is_admin?(Core.user.id)
    @u_role = @role_developer || @role_admin

    # 電子職員録 主管課権限設定
    @role_sb04_dev  = Gwsub::Sb04stafflistviewMaster.is_sb04_dev?

    @menu_header3 = 'sb0404menu'
    @menu_title3  = 'コード管理'
    @menu_header4 = 'sb04_seatlng_lists'
    @menu_title4  = '座席表'
    # 表示形式
    @v = nz(params[:v],@u_role==true ? '1':'2')
    if @v == '2'
      @menu_header3 = 'sb04_seatlng_lists'
      @menu_title3  = '座席表'
      @menu_header4 = nil
      @menu_title4  = nil
    end

    # 表示行数　設定
    @limits = nz(params[:limit],30)
    # 表示形式
    @v = nz(params[:v],'1')
    # 座席表を開く時のリンクで表示するツールチップ
    @bbs_link_title   = "別ウィンドウ・別タブで開きます"

    search_condition
    sortkeys_setting
    @css = %w(/_common/themes/gw/css/gwsub.css)
    case @v.to_i
    when 1
      @l1_current = '05'
      @l2_current = '01'
      @l3_current = '01'
    when 2
      @l1_current = '03'
      @l2_current = '01'
      @l3_current = '01'
    else
    end
  end

  def search_condition
    params[:limit] = nz(params[:limit], @limits)

    qsa = ['limit', 's_keyword' ,'fyed_id','grped_id' ,'pre_fyear' , 'v' ,'multi_section' ,'idx' ]
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end
  def sortkeys_setting
    @sort_keys = nz(params[:sort_keys], 'fyear_id DESC,bbs_url ASC')
  end

  def create_bbs_docs
    @item = Gwsub::Sb04SeatingList.find(params[:id])

    # 掲示板 ID 取得
    bbs_url = @item.bbs_url
    title_id_position = bbs_url.scan(/(title_id)=([\d]+)/)
    return '1' if title_id_position.blank?
    save_ldap_codes = Array.new

    title_id = title_id_position[0][1].to_i

    # 対象年度の所属一覧を取得
    group           = Gwsub::Sb04section.new
    group.fyear_id  = @item.fyear_id
    groups          = group.find(:all)
    # 記事枠登録
    params['title_id'] = title_id
    @title = Gwbbs::Control.find_by_id(title_id)

    if @title.dbname.blank?
    else
      item = gwbbs_db_alias(Gwbbs::Doc)
      item = item.new
      connect = item.connection()

      truncate_query1 = "TRUNCATE TABLE gwbbs_categories ;"
      connect.execute(truncate_query1)
      truncate_query2 = "TRUNCATE TABLE gwbbs_comments ;"
      connect.execute(truncate_query2)
      truncate_query3 = "TRUNCATE TABLE gwbbs_db_files ;"
      connect.execute(truncate_query3)
      truncate_query4 = "TRUNCATE TABLE gwbbs_docs ;"
      connect.execute(truncate_query4)
      truncate_query5 = "TRUNCATE TABLE gwbbs_files ;"
      connect.execute(truncate_query5)
      truncate_query6 = "TRUNCATE TABLE gwbbs_recognizers ;"
      connect.execute(truncate_query6)
    end
    default_published = 240 unless default_published  # 公開停止は240ヶ月先
    groups.each do |g|
      next if g.ldap_code=='00000'
      next if g.ldap_code.blank?

      # 年度開始日取得
      fyear_start_at  = Gw::YearFiscalJp.find(@item.fyear_id).start_at

      case g.ldap_code.size
      when 5
        ldap_group_code = g.ldap_code.to_s+'0'
      else
        ldap_group_code = g.ldap_code.to_s
      end
      group_condition =   "state='enabled' and code='#{ldap_group_code}'"
      group_condition <<  " and start_at <= '#{fyear_start_at}'"
      group_condition <<  " and ( (end_at is null) or (end_at >= '#{fyear_start_at}') ) "
      group_order     = "code , start_at DESC , end_at is null , end_at DESC"
      group           = System::Group.find(:first,:order=>group_order,:conditions=>group_condition)
      if group.blank?
        pp ['create_bbs_docs','group unmatch',g.fyear_markjp,g.code,g.name,g.ldap_code,fyear_start_at]
      else
        ldap_name = g.ldap_name
        if save_ldap_codes.empty?
          save_ldap_code = nil
        else
          save_ldap_code = save_ldap_codes.assoc(g.ldap_code)
        end
        unless save_ldap_code.blank?
          g.bbs_url   = "/gwbbs/docs/#{save_ldap_code[1]}?title_id=#{title_id}&limit=20&state=GROUP"
          g.ldap_name = ldap_name
          g.save(:validate => false)
        else
          item                    = gwbbs_db_alias(Gwbbs::Doc)
          item                    = item.new
          item.state              = 'public'
          item.title_id           = title_id
          item.latest_updated_at  = Time.now
          item.importance         = 1
          item.one_line_note      = 0
          item.title              = g.ldap_code+ldap_name+' 事務分掌表・座席表'
          item.body               = ''
          item.able_date          = Time.now.strftime("%Y-%m-%d")
          item.expiry_date        = default_published.months.since.strftime("%Y-%m-%d")
          item.section_code       = ldap_group_code
          item.section_name       = ldap_name
          item.createdate         = Time.now.strftime("%Y-%m-%d %H:%M")
          item.creater_id         = g.ldap_code
          item.creater            = g.ldap_code+ldap_name
          item.createrdivision_id = g.ldap_code
          item.createrdivision    = g.ldap_code+ldap_name
          item.editdate           = Time.now.strftime("%Y-%m-%d %H:%M")
          item.editor             = g.ldap_code+ldap_name
          item.editordivision     = g.ldap_code+ldap_name
          item.editor_id          = g.ldap_code
          item.editordivision_id  = g.ldap_code
          item.save(:validate => false)
          # 所属名から職員名簿用所属IDを取得し、座席表ページのURLを設定
          g.bbs_url   = "/gwbbs/docs/#{item.id}?title_id=#{title_id}&limit=20&state=GROUP"
          g.ldap_name = ldap_name
          g.save(:validate => false)
        end
        save_ldap_codes << [g.ldap_code, item.id]
      end
    end
    return '0'
  end

  def geturl_bbs_docs
    @item = Gwsub::Sb04SeatingList.find(params[:id])

    # 掲示板 ID 取得
    bbs_url           = @item.bbs_url
    title_id_position = bbs_url.scan(/(title_id)=([\d]+)/)
    return '1' if title_id_position.blank?

    title_id = title_id_position[0][1].to_i

    # 記事一覧取得 （公開で期限内の記事のみを対象とする）
    params[:title_id] = title_id
    @title  = Gwbbs::Control.find_by_id(title_id)
    item    = gwbbs_db_alias(Gwbbs::Doc)
    item    = item.new
    doc_cond = "title_id=#{params[:title_id]} and state='public' and "+" '" + Time.now.strftime("%Y/%m/%d %H:%M:%S") + "' between able_date and expiry_date"
    doc_order = "section_code ASC , latest_updated_at ASC"
    items   = item.find(:all,:conditions=>doc_cond , :order=>doc_order)
    return '2' if items.blank?

    # 指定年度の所属から、URLをクリア
    Gwsub::Sb04section.update_all( "bbs_url=''" , "fyear_id=#{@item.fyear_id}" )

    # 座席表記時のURLを設定
    items.each do |bbs|
      # 記事一括登録時の見出し(title)は、所属コード５桁＋所属名＋' 座席表'
      section               = Gwsub::Sb04section.new
      item_section_title    = bbs.title.split(' ')
      item_section          = item_section_title[0]
      
      ldap_code             = item_section.slice(0, 6)
      if ldap_code !~  /^[0-9A-Za-z]+$/ # 半角英数字以外の文字列が含まれていた場合
        ldap_name               = item_section.slice(5, item_section.size - 5)
        ldap_code               = item_section.slice(0,5) + '0'
      else
        ldap_name               = item_section.slice(6, item_section.size - 6)
      end
      
      section_order = "fyear_id DESC , code ASC , id DESC "
      section_cond = "fyear_id = #{@item.fyear_id} and ldap_code='#{ldap_code}'"
      @sections = section.find(:all,:conditions=>section_cond,:order=>section_order)

      unless @sections.empty?

        @sections.each do |section|
          section.ldap_name  = ldap_name
          section.bbs_url    = "/gwbbs/docs/#{bbs.id}?title_id=#{title_id}&limit=20&state=GROUP"
          section.save(:validate => false)
        end
      end
    end
    return '0'
  end

end
