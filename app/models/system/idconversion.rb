# encoding: utf-8
class System::Idconversion < ActiveRecord::Base
  include System::Model::Base
  include System::Model::Tree
  include System::Model::Base::Config

  validates_presence_of :tablename
  validates_uniqueness_of :tablename

  def self.convert( _model ,_tablename )
    _cols = eval(_model).column_names
    _items = eval(_model).find(:all)

    _alter_uid = 0
    _alter_workser_id = 0
    _alter_user_id = 0
    _alter_group_id = 0

    _items.each do | _item |
      _item_update = eval(_model).find(_item.id)

      _cols.each do | _col |
        case _col
        when  'uid'
          _alter_uid = 1
          _user_id = get_user_id(_item.uid)
          _item_update.uid = _user_id
        when  'worker_id'
          _alter_workser_id = 1
          _user_id = get_user_id(_item.worker_id)
          _item_update.worker_id = _user_id
        when  'user_id'
          _alter_user_id = 1
          _user_id = get_user_id(_item.user_id)
          _item_update.user_id = _user_id
        when  'group_id'
          _alter_group_id = 1
          _group_id = get_group_id(_item.group_id)
          _item_update.group_id = _group_id
        end
      end
      _item_update.save
    end
    if  _alter_uid == 1
      change_column( _tablename, 'uid', integer )
    end
    if  _alter_workser_id == 1
      change_column( _tablename, 'worker_id', integer )
    end
    if  _alter_user_id == 1
      change_column( _tablename, 'user_id', integer )
    end
    if  _alter_group_id == 1
      change_column( _tablename, 'group_id', integer )
    end

    return true
  end

  def self.get_user_id(_user_id1)
    if _user_id1.blank?
        _user_id = nil
    else
      _user = System::User.find(:first , :conditions=>"code='#{_user_id1}'")
      if _user == nil
        _user_id = nil
      else
        _user_id = _user.id
      end
    end
    return _user_id
  end

  def self.get_group_id(_group_id1)
    if _group_id1.blank?
        _group_id = nil
    else
      _version_id = System::GroupVersion.get_current_group_version_id
      _group = System::Group.find(:first , :conditions=>"code='#{_group_id1}' and version_id='#{_version_id}'")
      if _group == nil
        _group_id = nil
      else
        _group_id = _group.id
      end
    end
    return _group_id
  end
end
