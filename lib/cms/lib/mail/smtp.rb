require 'nkf'
class Cms::Lib::Mail::Smtp < ActionMailer::Base

  def self.settings
    ActionMailer::Base.smtp_settings = {
      :address => 'localhost',
      :port => 25,
      :domain => 'localhost',
    }
  end

  def recognition(mail_fr, mail_to, subject, message)
    self.class.settings
    from       mail_fr
    recipients mail_to
    subject    subject
    body       message
  end

end