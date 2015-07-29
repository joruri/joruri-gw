# encoding: utf-8
class Sys::User < Sys::MailPref
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Rel::RoleName
  include Sys::Model::Auth::Manager

end
