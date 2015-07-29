# encoding: utf-8
module Gw::NameValue
  PATH_SEPARATOR = '/'

  def self.nz(value, valueifnull='')
    value.blank? ? valueifnull : value
  end

  def self.get_cache(type, section, key, criteria='')
    c_key = "Gw::NameValue.get_" + type.to_s + "_" + section.to_s + "_" + key.to_s + "_" + criteria.to_s
    begin
      value = Rails.cache.read(c_key)
      if value.nil?
        value = self.get type, section, key, criteria
        Rails.cache.write(c_key, value, :expires_in => 3600)
      else
      end
    rescue
      value = self.get type, section, key, criteria
    end
    return value
  end

  def self.get(type, section, key, criteria='')
    case type
    when 'yaml'
      wrk_hash_raw = Gw.load_yaml_files(section)
      item = hash_getter(wrk_hash_raw, key)
      return nz(item, {})
    when 'model'
      item = section.new
      @items = item.find(:all, :conditions=>criteria)
      wrk_ary = []
      @items.each {|itemx|
        wrk_ary.push itemx[key]
      }
      wrk_ary.length == 1 ? wrk_ary[0] : wrk_ary
    when 'dbraw'
      split_section = section.split(/\//)
      ::Ar rescue eval('::Ar = Class.new ActiveRecord::Base')
      if split_section.length==1
        _section = section
        _ec = RAILS_ENV
      else
        _section = split_section[1]
        _ec = split_section[0]
        db_config = ActiveRecord::Base.configurations
        raise TypeError, %Q[unknown database descriptor(#{_ec}), please set standard model manually.] unless db_config.has_key?(_ec)
      end
      ::Ar.establish_connection _ec
      ::Ar.set_table_name _section
      items = ::Ar.find(:all, :select => key, :conditions => criteria)
      items.length == 1 ? items[0].send(key) : items
    else
      raise TypeError, "unknown type(#{type})"
    end
  end

  def self.hash_getter(hash, key)
    split_key = key.split(/#{PATH_SEPARATOR}/)
    if split_key.length == 1
      last_key = Gw.to_int(split_key[0]) rescue split_key[0]
      return HashWithIndifferentAccess.new(hash[last_key])
    end
    wrk_key = split_key[0]
    split_key.shift
    return HashWithIndifferentAccess.new(hash_getter(hash[wrk_key], split_key.join("#{PATH_SEPARATOR}")))
  end

end
