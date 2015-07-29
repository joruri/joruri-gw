# encoding: utf-8
class System::Publisher < ActiveRecord::Base
  include System::Model::Base

  validates_presence_of :unid

  before_destroy :close

  def close
    path = published_path
    File.delete(path) if FileTest.exist?(path)

    begin
      Dir::rmdir(File::dirname(path))
    rescue
      return true
    end
    return true
  end
end
