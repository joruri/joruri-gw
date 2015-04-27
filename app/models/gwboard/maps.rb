class Gwboard::Maps < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  after_validation :address_validate

  before_save :map_url


  def address_validate

    if self.address.blank?
      errors.add :address, '住所 または 緯度・経度の いずれかを入力してください。'
    end if self.latitude.blank? if self.longitude.blank?

    no_error = true

    unless self.latitude.blank?

      if self.longitude.blank?
        errors.add :longitude, '経度を入力してください。'
        no_error = false
      end

      unless self.latitude.to_s =~ /^[+-]?\d+\.?\d*$/
        errors.add :latitude, '緯度の入力形式に誤りがあります。'
        no_error = false
      end
    end

    unless self.longitude.blank?

      if self.latitude.blank?
        errors.add :latitude, '緯度を入力してください。'
        no_error = false
      end
      unless self.longitude.to_s =~ /^[+-]?\d+\.?\d*$/
        errors.add :longitude, '経度の入力形式に誤りがあります。'
        no_error = false
      end
    end

    self.latlong = ''
    self.latlong = "#{self.latitude.to_s},#{self.longitude.to_s}" unless self.latitude.blank? unless self.longitude.blank? if no_error
  end


  def map_url
    str = "http://maps.google.co.jp/maps?"
    str += "f=q&hl=ja"
    str += "&q=#{URI.encode(self.address)}" if self.latlong.blank?
    str += "&q=#{URI.encode(self.latlong)}" unless self.latlong.blank?
    str += "+(#{URI.encode(self.memo)})"
    str += "&z=19"
    str += "&output=embed"
    self.url = str
  end

  def link_memo
    str = '地図'
    str = self.address unless self.address.blank? if self.memo.blank?
    str = self.memo unless self.memo.blank?
    return str
  end

  def base_info
    str = ''
    str = "(#{self.latlong})" unless self.latlong.blank?
    str = self.address if self.latlong.blank?
    return str
  end

  def icon_type
    return 'iconFile iconMap'
  end
end
