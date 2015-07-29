class DefaultMailer < ActionMailer::Base
  default :charset => "UTF-8"
  
#  def send_message(msg)
#    mail(
#      :from    => msg.from,
#      :to      => msg.to_addrs,
#      :cc      => msg.cc_addrs,
#      :bcc     => msg.bcc_addrs,
#      :subject => msg.subject
#    ) do |format|
#      #format.html { msg.body.decoded }
#      format.text { msg.body.decoded }
#      
#      msg.attachments.each do |f|
#        name = f.original_filename
#        name = NKF.nkf('-jM', name).split.join if charset.downcase == 'iso-2022-jp'
#        name = NKF.nkf('-wM', name).split.join if charset.downcase == 'utf-8'
#        attachments[name] = {:content => f.read, :mime_type => f.mime_type}
#      end
#    end
#  end
end
