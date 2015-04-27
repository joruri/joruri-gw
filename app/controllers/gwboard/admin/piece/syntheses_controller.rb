class Gwboard::Admin::Piece::SynthesesController < ApplicationController
  include System::Controller::Scaffold
  layout false

  def init_params
    @setup = Gwboard::Synthesetup.where(content_id: 0).first

    case Gwboard::Synthesetup.where(content_id: 2).first.try(:limit_date)
    when 'today'
      @msg = '本日'
      @date = Date.today
    when 'yesterday'
      @msg = '前日から'
      @date = Date.yesterday
    when '3.days'
      @msg = '3日前から'
      @date = 3.days.ago
    when '4.days'
      @msg = '4日前から'
      @date = 4.days.ago
    else
      @msg = '本日'
      @date = Date.yesterday
    end
  end

  def index
    init_params
    if @setup
      index_gwbbs if @setup.gwbbs_check
      index_gwfaq if @setup.gwfaq_check
      index_gwqa if @setup.gwqa_check
      index_doclib if @setup.doclib_check
      index_digitallib if @setup.digitallib_check
    end

    @none_dsp = [@bbs_docs, @faq_docs, @qa_docs, @doclib_docs, @digitallib_docs].all?(&:zero?)
  end

  private

  def index_gwbbs
    @bbs_docs = Gwbbs::Doc.public_docs.latest_updated_since(@date).with_notification_enabled.satisfy_restrict_access
      .tap{|d| break d.with_readable_role(Core.user) unless Gwbbs::Control.is_sysadm? }
      .distinct(:id).count
  end

  def index_gwfaq
    @faq_docs = Gwfaq::Doc.public_docs.latest_updated_since(@date).with_notification_enabled
      .tap{|d| break d.with_readable_role(Core.user) unless Gwfaq::Control.is_sysadm? }
      .distinct(:id).count
  end

  def index_gwqa
    @qa_docs = Gwqa::Doc.public_docs.latest_updated_since(@date).with_notification_enabled
      .tap{|d| break d.with_readable_role(Core.user) unless Gwfaq::Control.is_sysadm? }
      .distinct(:id).count
  end

  def index_doclib
    @doclib_docs = Doclibrary::Doc.public_docs.latest_updated_since(@date).with_notification_enabled
      .tap{|d| break d.with_readable_role(Core.user).in_readable_folder(Core.user) unless Doclibrary::Control.is_sysadm? }
      .distinct(:id).count
  end

  def index_digitallib
    @digitallib_docs = Digitallibrary::Doc.public_docs.latest_updated_since(@date).with_notification_enabled
      .tap{|d| break d.with_readable_role(Core.user) unless Digitallibrary::Control.is_sysadm? }
      .distinct(:id).count
  end
end
