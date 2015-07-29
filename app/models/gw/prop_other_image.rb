# encoding: utf-8
class Gw::PropOtherImage < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :other, :foreign_key => :parent_id, :class_name => 'Gw::PropOther'
  def self.drop_create_table
    table_name = Gw.tablize self.name
    _connect = self.connection()

    _create_query = "create table #{table_name} (
      `id`            int(11) unsigned NOT NULL auto_increment,
      `parent_id`     int(11) default NULL,
      `idx`           int(11) default NULL,
      `note`          varchar(255) default NULL,
      `path`          varchar(255) default NULL,
      `orig_filename` varchar(255) default NULL,
      `content_type`  varchar(255) default NULL,
      `created_at`    datetime default NULL,
      `updated_at`    datetime default NULL,
      PRIMARY KEY  (`id`)
    ) DEFAULT CHARSET=utf8;"
    _connect.execute(_create_query)
    return
  end
  
  def _size
    path = "public#{self.path}"
    size = ''
    if File.exists?(path) && File.stat(path).ftype == 'file'
      s = File.stat path
      siz = s.size.to_f
      case
      when siz > 1.kilobytes
        size += "#{(siz / 1.kilobytes).round 1}KB"
      when siz > 1.megabytes
        size += "#{(siz / 1.megabytes).round 1}MB"
      else
        size += "#{siz}"
      end
      require 'RMagick'
      img = Magick::ImageList.new(path) rescue nil
      size += !img.nil? ? "(#{img.columns}x#{img.rows})" : ''
    end
    nz(size)
  end
end
