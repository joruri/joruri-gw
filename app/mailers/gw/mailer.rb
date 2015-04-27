class Gw::Mailer < DefaultMailer

  def memo_mail(options = {from: '', to: '', subject: '', item: nil})
    @item = options[:item]
    mail from: options[:from], to: options[:to], subject: options[:subject]
  end
end
