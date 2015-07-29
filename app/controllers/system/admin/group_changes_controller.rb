# encoding: utf-8
class System::Admin::GroupChangesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/admin"

  def initialize_scaffold
    Page.title = "組織変更"
    @role_developer  = System::User.is_dev?
    @role_admin      = System::User.is_admin?
    @role_editor     = System::User.is_editor?
    @u_role = @role_developer || @role_admin || @role_editor

    @limit = nz(params[:limit],30)
    @css = %w(/layout/admin/style.css)
    return redirect_to "/_admin" unless @u_role
    @start_at = get_start_at
  end

  def get_start_at
    fyears = System::GroupChangeDate.find(:first , :order=>"start_at DESC")
    if fyears.blank?
      return nil
    end
    if fyears.start_at.blank?
      return nil
    end

    start_at_str = fyears.start_at.strftime("%Y-%m-%d 00:00:00")
    return start_at_str
  end

  def index

    item = Gwboard::RenewalGroup.new
    show_start_at = @start_at
    if !show_start_at.blank?
      item.and :start_date, show_start_at
    end
    item.order :incoming_group_code
    @items = item.find(:all)
  end

  def show
    @item = Gwboard::RenewalGroup.find_by_id(params[:id])
  end

  def new
    @item = Gwboard::RenewalGroup.new({
      :start_date => @start_at
    }
    )
  end

  def create
    @item = Gwboard::RenewalGroup.new(params[:item])
    @item.start_date = @start_at if @item.start_date.blank?
    _create @item
  end

  def edit
    @item = Gwboard::RenewalGroup.find_by_id(params[:id])
  end

  def update
    @item = Gwboard::RenewalGroup.find_by_id(params[:id])
    @item.attributes = params[:item]
    if @item.save
      flash[:notice]="組織変更データを編集しました"
    else
      flash[:notice]="組織変更データの編集に失敗しました"
    end
    _update @item
  end


  def destroy
    @item = Gwboard::RenewalGroup.find(:first,:conditions=>["id = ?",params[:id]])
    _destroy @item
  end


  def csvup
    if params[:do] == "up" && params[:item] && params[:item][:file]
      invalid_filetype = false
      if params[:item][:file].original_filename =~ /csv/
        ret = import_csv_data(params,@start_at)
      else
        invalid_filetype = true
        ret = {:result => false}
      end
      if ret[:result]
        flash[:notice]="#{ret[:count]}件のデータを登録しました。"
        return redirect_to url_for({:action=>:index})
      else
        if invalid_filetype
          flash[:notice]="選択された種別と、実際のファイル拡張子が異なっています。"
        else
          flash[:notice]="CSVの解析に失敗しました。"
        end
        return redirect_to url_for({:action=>:csv_up})
      end
    end
  end


  def import_csv_data(params, start_at)
    require 'csv'
    column = nil
    data = nil
    count = 0
    csv = NKF.nkf('-w', params[:item][:file].read)
    CSV.parse(csv) do |row|
      if column.blank?
        column = row
        next
      else
        data = {}
        row.each_with_index{|row_item, i|
          next if row_item.blank?
          next if column[i].blank?
          data[column[i].to_sym] = row_item
        }
      end
      unless data[:present_group_id]
        present_group = System::Group.new
        present_group.and "sql", "end_at IS NULL"
        present_group.and :state , "enabled"
        present_group.and :code, data[:present_group_code]
        p_group = present_group.find(:first)
        data[:present_group_id] = p_group.id if p_group
      end
      item = Gwboard::RenewalGroup.new
      item.start_date = start_at
      item.attributes = data
      item.save
      count += 1
    end
    return {:result => true, :count => count}
  end

  def do_annual_change(start_at)
    item = Gwboard::RenewalGroup.new
    item.and :start_date, start_at
    items = item.find(:all)
    return false if items.blank?
    items.each do |p_item|
      next unless p_item.incoming_group_id.blank?
      incoming_group = System::Group.new
      incoming_group.and "sql", "end_at IS NULL"
      incoming_group.and :state , "enabled"
      incoming_group.and :code, p_item.incoming_group_code
      i_group = incoming_group.find(:first)
      if i_group.blank?
        return false
      else
        p_item.incoming_group_id = i_group.id
        p_item.save(:validate => false)
      end
    end

    Gwbbs::Script::Annual.renew(start_at)
    Gwqa::Script::Annual.renew(start_at)
    Gwfaq::Script::Annual.renew(start_at)
    Doclibrary::Script::Annual.renew(start_at)
    Digitallibrary::Script::Annual.renew(start_at)
    Gwmonitor::Script::Annual.renew(start_at)
    System::Script::Annual.system_roles_renew(start_at)
    Gw::Script::Annual.renew(start_at)
    Questionnaire::Script::Annual.renew(start_at)

  end

  def reflect
    msg = ""
    if do_annual_change(@start_at)
      msg = "作業を終了しました。"
    else
      msg = "組織変更情報が存在しないか、新所属の設定に誤りがあります。"
    end
    flash[:notice]=msg
    return redirect_to url_for({:action=>:index})
  end

end
