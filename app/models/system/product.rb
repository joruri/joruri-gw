class System::Product < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :product_type, :name

  def ssos
    [['利用する',1],['利用しない',0]]
  end

  def sso_label
    ssos.rassoc(sso).try(:first)
  end

  def sso_enabled?
    sso == 1
  end

  def product_synchros
    [['利用する',1],['利用しない',0]]
  end

  def product_synchro_label
    product_synchros.rassoc(product_synchro).try(:first)
  end

  def product_synchro_enabled?
    product_synchro == 1
  end

  def sso_uri
    URI(sso_url) rescue nil
  end

  def sso_uri_mobile
    URI(sso_url_mobile.presence || sso_url) rescue nil
  end

  def editable?
    product_type != 'gw'
  end

  def deletable?
    product_type != 'gw'
  end

  def self.available_sso_options
    self.where(:sso => 1).order(:sort_no).select(:product_type, :name).map{|p| ["SSO to #{p.name}", p.product_type]}
  end

  def self.available_product_synchro_options
    self.where(:product_synchro => 1).order(:sort_no).select(:product_type, :name).map{|p| ["SSO to #{p.name}", p.product_type]}
  end
end
