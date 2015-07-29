################################################################################
# 個別業務(gwsub)：広報依頼(sb05)：メルマガ：イベント情報
#  添付画像一覧
################################################################################

class Gwsub::Admin::ReceiptsController < ApplicationController
  include System::Controller::Scaffold

  def initialize_scaffold

  end

  def show_object
    item = Gwsub::Sb05File.find_by_id(params[:id])
    object = Gwsub::Sb05DbFile.find(item.db_file_id)
    send_data(object.data, :disposition =>"inline", :type => item.content_type)
  end

  def download_object

    #admin_flags
    #get_readable_flag unless @is_readable
    #return authentication_error(403) unless @is_readable    #閲覧権無ければ403
#    if params[:system]=='mailinglist'
#      item = Gwsub::Sb10ProposalMailinglistFile
#    elsif params[:system]=='software'
#      item = Gwsub::Sb10ProposalSoftwareFile
#    elsif params[:system]=='terminal_conference'
#      item = Gwsub::Terminalconferencefile
#    end
    case params[:system]
    when "sb01_training"
      item = Gwsub::Sb01TrainingFile.new
    when "sb10_mailinglist"
      item = Gwsub::Sb10ProposalMailinglistFile.new
    when "sb10_software"
      item = Gwsub::Sb10ProposalSoftwareFile.new
    when "sb10_personnel_change"
      item = Gwsub::Sb10ProposalPersonnelChangeFile.new
    when "sb09_terminal_conference"
      item = Gwsub::Terminalconferencefile.new
    when "sb05_requests"
      item = Gwsub::Sb05File.new
    else
      item = nil
    end
    return if item==nil

#    item = item.find_by_id(params[:id])
    item = item.find(params[:id])

    #IE判定
    user_agent = request.headers['HTTP_USER_AGENT']
    chk = user_agent.index("MSIE")
    chk = user_agent.index("Trident") if chk.blank?
    if chk.blank?
      item_filename = item.filename
    else
      item_filename = item.filename.tosjis
    end

    #制御付き実ファイル

    f = open(item.f_name)
    send_data(f.read, :filename => item_filename, :type => item.content_type)
    f.close

  end
end
