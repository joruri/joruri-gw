class Gw::Property::MemoAdminDelete < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 3, name: "memo", type_name: "json" }
  end

  def default_options
    { memos: { read_memos_admin_delete: '1', unread_memos_admin_delete: '1' } }
  end

  def memos
    options_value['memos'] || {}
  end

  def read_memos_admin_delete
    memos['read_memos_admin_delete']
  end

  def unread_memos_admin_delete
    memos['unread_memos_admin_delete']
  end

  def delete_options
    [['５日','1'],['１０日','2'],['２０日','3'],['３０日','4']]
  end
end
