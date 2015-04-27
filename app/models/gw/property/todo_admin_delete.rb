class Gw::Property::TodoAdminDelete < Gw::UserProperty
  default_scope { where(self.new.default_attributes) }

  def default_attributes
    { class_id: 3, name: "todo", type_name: "json" }
  end

  def default_options
    { todos: { todos_admin_delete: '4' } }
  end

  def todos
    options_value['todos'] || {}
  end

  def todos_admin_delete
    todos['todos_admin_delete']
  end

  def admin_delete_options
    I18n.a('enum.gw/property/todo_admin_delete.admin_delete_options')
  end
end
