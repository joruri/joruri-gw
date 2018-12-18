class UpdateSsoUrlMobileOnSystemProducts < ActiveRecord::Migration
  def up
    if mobile_mail = Gw::UserProperty.where(name: 'mobile_mail', type_name: 'sso').first
      mobile_ssl = Gw::UserProperty.where(name: 'mobile_ssl', options: 'true').first
      scheme = mobile_ssl.present? ? 'https': 'http'
      if mail = System::Product.where(product_type: 'mail').first
        mail.update_column(:sso_url_mobile, "#{scheme}://#{mobile_mail.options}/_admin/air_sso")
      end
    end
    Gw::UserProperty.where(name: 'sso', type_name: ['mail', 'sns', 'video', 'maps', 'hcs']).all.each do |prop|
      options = prop.options_value
      scheme = options["use_ssl"] ? 'https' : 'http'
      product_type = prop.type_name == 'sns' ? 'plus' : prop.type_name
      if product = System::Product.where(product_type: product_type).first
        product.update_column(:sso_url, "#{scheme}://#{options["host"]}:#{options["port"]}/#{options["path"]}")
      end
    end
  end

  def down
  end
end
