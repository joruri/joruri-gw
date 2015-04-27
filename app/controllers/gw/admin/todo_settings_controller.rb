class Gw::Admin::TodoSettingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/todo"

  def pre_dispatch
    Page.title = "ToDo設定"
    @css = %w(/_common/themes/gw/css/todo.css)
  end

  def reminder
    @item = Gw::Property::TodoSetting.where(uid: Core.user.id).first_or_new
  end

  def edit_reminder
    @item = Gw::Property::TodoSetting.where(uid: Core.user.id).first_or_new
    @item.options_value = @item.options_value.deep_merge(params[:item])

    if @item.save
      flash_notice('設定編集処理', true)
      redirect_to "/gw/todo_settings"
    else
      render :reminder
    end
  end

  def schedule
    @item = Gw::Property::TodoSetting.where(uid: Core.user.id).first_or_new
  end

  def edit_schedule
    @item = Gw::Property::TodoSetting.where(uid: Core.user.id).first_or_new
    @item.options_value = @item.options_value.deep_merge(params[:item])

    if @item.save
      flash_notice('設定編集処理', true)
      redirect_to "/gw/todo_settings"
    else
      render :schedule
    end
  end

  def admin_deletes
    return error_auth unless Core.user.has_role?('_admin/admin')

    @item = Gw::Property::TodoAdminDelete.first_or_new
  end

  def edit_admin_deletes
    return error_auth unless Core.user.has_role?('_admin/admin')

    @item = Gw::Property::TodoAdminDelete.first_or_new
    @item.options_value = params[:item]

    if @item.save
      flash_notice('ToDo削除設定処理', true)
      redirect_to "/gw/config_settings?c1=1&c2=7"
    else
      render :edit_admin_deletes
    end
  end
end
