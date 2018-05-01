# encoding: utf-8
## schedule
puts "Import schedule demo"

car         = Gw::PropType.where(id: 100).first
meetingroom = Gw::PropType.where(id: 200).first
fixtures    = Gw::PropType.where(id: 300).first

def create_prop(prop_type, name, sort_no, admin_group)

  prop = Gw::PropOther.create({
    type_id: prop_type.id,
    reserved_state: 1,
    delete_state: 0,
    state: 'enabled',
    sort_no: sort_no,
    name: name,
    gid: admin_group.id,
    gname: admin_group.name
  })
  if prop
    new_admin_group = Gw::PropOtherRole.new()
    new_admin_group.gid = admin_group.id
    new_admin_group.prop_id = prop.id
    new_admin_group.auth = 'admin'
    new_admin_group.created_at = 'now()'
    new_admin_group.updated_at = 'now()'
    new_admin_group.save


    new_edit_group = Gw::PropOtherRole.new()
    new_edit_group.gid = admin_group.id
    new_edit_group.prop_id = prop.id
    new_edit_group.auth = 'edit'
    new_edit_group.created_at = 'now()'
    new_edit_group.updated_at = 'now()'
    new_edit_group.save


    new_read_group = Gw::PropOtherRole.new()
    new_read_group.gid = admin_group.id
    new_read_group.prop_id = prop.id
    new_read_group.auth = 'read'
    new_read_group.created_at = 'now()'
    new_read_group.updated_at = 'now()'
    new_read_group.save
  end

end


g1 = System::Group.where(code: '001001').first
g2 = System::Group.where(code: '001002').first
g3 = System::Group.where(code: '001003').first

create_prop car, '１号車', 10, g1
create_prop car, '２号車', 20, g2
create_prop car, '３号車', 30, g3

create_prop meetingroom, '２０１会議室', 10, g1
create_prop meetingroom, '３０１会議室', 20, g2
create_prop meetingroom, '４０１会議室', 30, g3

create_prop fixtures, 'プロジェクター', 10, g1
create_prop fixtures, 'タブレット', 20, g2
create_prop fixtures, 'Wifi', 30, g3


