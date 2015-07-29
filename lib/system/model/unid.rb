# encoding: utf-8
module System::Model::Unid
  def self.included(mod)
    mod.has_one :unid_original, :primary_key => 'unid', :foreign_key => 'id', :class_name => 'System::Unid',
      :dependent => :destroy

    mod.after_save :save_unid
  end

  def save_unid
    return false if @saved_unid
    return true if unid
    @saved_unid = true

    _class  = self.class.to_s.split('::')
    _module = _class[0].underscore
    _itype  = _class[1].nil? ? 'published' : _class[1].underscore.pluralize
    _unid   = System::Unid.new({:module => _module, :item_type => _itype, :item_id => id})
    return false unless _unid.save

    self.unid = _unid.id

    sql = "UPDATE #{self.class.table_name} SET unid = (#{_unid.id}) WHERE id = #{id}"
    self.class.connection.execute(sql)
  end
end
