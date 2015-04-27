################################################################################
# 個別業務(gwsub)：広報依頼(sb05)：メルマガ：イベント情報
#  添付画像一覧
################################################################################

class Gwsub::Admin::ReceiptsController < ApplicationController
  include System::Controller::Scaffold
  include DownloadHelper

  def show_object
    item = Gwsub::Sb05File.where(:id => params[:id]).first
    object = Gwsub::Sb05DbFile.find(item.db_file_id)
    send_data(object.data, :disposition =>"inline", :type => item.content_type)
  end

  def download_object

    #admin_flags
    #get_readable_flag unless @is_readable
    #return error_auth unless @is_readable    #閲覧権無ければ403
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

#    item = item.where(:id => params[:id]).first
    item = item.find(params[:id])

    #制御付き実ファイル

    f = open(item.f_name)
    send_data(f.read, :filename => item.filename, :type => item.content_type)
    f.close

  end
end
