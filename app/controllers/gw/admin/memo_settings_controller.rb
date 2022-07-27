class Gw::Admin::MemoSettingsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/memo"

  def pre_dispatch
    Page.title = "連絡メモ設定"
    @css = %w(/_common/themes/gw/css/memo.css)
  end

  def index
  end

  def forwarding
    @item = Gw::Property::MemoMobileMail.where(uid: Core.user.id).first_or_new
  end

  def update_forwarding
    @item = Gw::Property::MemoMobileMail.where(uid: Core.user.id).first_or_new
    @item.options_value = forwarding_params

    if @item.save
      flash_notice('携帯等メール転送設定', true)
      redirect_to gw_memo_settings_path
    else
      render :forwarding
    end
  end

  def reminder
    @item = Gw::Property::MemoReminder.where(uid: Core.user.id).first_or_new
  end

  def edit_reminder
    @item = Gw::Property::MemoReminder.where(uid: Core.user.id).first_or_new
    @item.options_value = reminder_params

    if @item.save
      flash_notice('リマインダー表示設定の保存', true)
      redirect_to gw_memo_settings_path
    else
      render :reminder
    end
  end

  def admin_deletes
    return error_auth unless Core.user.has_role?('_admin/admin')

    @item = Gw::Property::MemoAdminDelete.first_or_new
  end

  def edit_admin_deletes
    return error_auth unless Core.user.has_role?('_admin/admin')

    @item = Gw::Property::MemoAdminDelete.first_or_new
    @item.options_value = admin_deletes_params

    if @item.save
      flash_notice('連絡メモ削除設定処理', true)
      redirect_to '/gw/config_settings?c1=1&c2=7'
    else
      render :admin_deletes
    end
  end

private

  def forwarding_params
    params.require(:item).permit(:mobiles => [:kmail, :ktrans])
  end

  def reminder_params
    params.require(:item).permit(:memos => [:read_memos_display, :unread_memos_display])
  end

  def admin_deletes_params
    params.require(:item).permit(:memos => [:read_memos_admin_delete, :unread_memos_admin_delete])
  end


end
