# encoding: utf-8
class Sys::Lib::Ldap::User < Sys::Lib::Ldap::Entry
  ## Initializer.
  def initialize(connection, attributes = {})
    super
    @primary = "uid"
    @filter  = "(&(objectClass=top)(objectClass=organizationalPerson))"
  end
  
  ## Attribute: uid
  def uid
    get(:uid)
  end
  
  ## Attribute: name
  def name
    get(:cn)
  end
  
  ## Attribute: name(english)
  def name_en
    "#{get('sn;lang-en')} #{get('givenName;lang-en')}".strip
  end
  
  ## Attribute: email
  def email
    get(:mail)
  end
  
  ## Attribute: kana
  def kana
    #get(:cn, 1)
    "#{get('cn;lang-ja;phonetic')}"
  end
  
  ## Attribute: sort_no
  def sort_no
    get(:departmentNumber)
  end

  ## Attribute: official_position
  def official_position
    get(:title)
  end
  
  ## Attribute: assigned_job
  def assigned_job
    get(:employeeType)
  end
end
