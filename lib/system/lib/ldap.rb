# encoding: utf-8
require 'ldap'
require 'ldap/ldif'
require 'nkf'
class System::Lib::Ldap
  def self.bind(uid, passwd, reconn = false)

    config  = Util::Config.load 'ldap'
    host    = config['host']
    port    = config['port']
    base    = config['base'].to_s

    u       = System::User.new.enabled
    u.code  = uid
    user    = u.find(:first)
    ou1     = System::Group.find(user.groups[0].group_id)
    ou2     = ou1.parent
    user_dn = "uid=#{uid},ou=#{ou1.ou_name},ou=#{ou2.ou_name}"

    begin
      conn = LDAP::Conn.new(host, port)
      conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
      if(RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|bccwin/)
        bind_name = NKF.nkf('-s -W', "#{user_dn},#{base}")
      else
        bind_name = "#{user_dn},#{base}"
      end

      conn.bind(bind_name, passwd)

      return conn
    rescue => e
      conn  = nil
    end
    return false
  rescue ActiveRecord::RecordNotFound
    return false
  end

end