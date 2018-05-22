class Gwboard::Admin::SynthesesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  layout "admin/template/portal_1column"

  def pre_dispatch
    @date =
      case Gwboard::Synthesetup.where(content_id: 2).first.try(:limit_date)
      when 'today'
        Date.today
      when 'yesterday'
        Date.yesterday
      when '3.days'
        3.days.ago
      when '4.days'
        4.days.ago
      when '5.days'
        5.days.ago
      when '6.days'
        6.days.ago
      when '7.days'
        7.days.ago
      when '14.days'
        14.days.ago
      else
        Date.yesterday
      end
    dump @date
    Page.title = "掲示板新着総合案内"
    @css = ["/_common/themes/gw/css/gwbbs_standard.css"]

    params[:limit] = 50
    params[:system] ||= 'gwbbs'
  end

  def index
    case params[:system]
    when 'gwbbs'
      index_gwbbs
    when 'gwfaq'
      index_gwfaq
    when 'gwqa'
      index_gwqa
    when 'doclibrary'
      index_doclib
    when 'digitallibrary'
      index_digitallib
    end
  end

  def index_gwbbs
    @items = Gwbbs::Doc.select(:id, :title_id, :title, :section_name, :latest_updated_at)
      .public_docs.latest_updated_since(@date).with_notification_enabled.satisfy_restrict_access
      .tap{|d| break d.with_readable_role(Core.user) unless Gwbbs::Control.is_sysadm? }
      .order(latest_updated_at: :desc).distinct
      .paginate(page: params[:page], per_page: params[:limit])
      .preload(:control)
  end

  def index_gwfaq
    @items = Gwfaq::Doc.select(:id, :title_id, :title, :section_name, :latest_updated_at)
      .public_docs.latest_updated_since(@date).with_notification_enabled
      .tap{|d| break d.with_readable_role(Core.user) unless Gwfaq::Control.is_sysadm? }
      .order(latest_updated_at: :desc).distinct
      .paginate(page: params[:page], per_page: params[:limit])
      .preload(:control)
  end

  def index_gwqa
    @items = Gwqa::Doc.select(:id, :title_id, :doc_type, :title, :section_name, :latest_updated_at, :parent_id)
      .public_docs.latest_updated_since(@date).with_notification_enabled
      .tap{|d| break d.with_readable_role(Core.user) unless Gwqa::Control.is_sysadm? }
      .order(latest_updated_at: :desc).distinct
      .paginate(page: params[:page], per_page: params[:limit])
      .preload(:control)
  end

  def index_doclib
    @items = Doclibrary::Doc.select(:id, :title_id, :category1_id, :title, :section_name, :latest_updated_at)
      .public_docs.latest_updated_since(@date).with_notification_enabled
      .tap{|d| break d.with_readable_role(Core.user).in_readable_folder(Core.user) unless Doclibrary::Control.is_sysadm? }
      .order(latest_updated_at: :desc).distinct
      .paginate(page: params[:page], per_page: params[:limit])
      .preload(:control)
  end

  def index_digitallib
    @items = Digitallibrary::Doc.select(:id, :title_id, :title, :section_name, :latest_updated_at)
      .public_docs.latest_updated_since(@date).with_notification_enabled
      .tap{|d| break d.with_readable_role(Core.user) unless Digitallibrary::Control.is_sysadm? }
      .order(latest_updated_at: :desc).distinct
      .paginate(page: params[:page], per_page: params[:limit])
      .preload(:control)
  end
end
