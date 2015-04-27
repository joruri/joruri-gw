class Gwsub::Sb05File < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content
  include Gwsub::Model::AttachFile
  include Gwsub::Model::Systemname #システム固定名

  validates_presence_of :filename, :message => "ファイルが指定されていません。"

  FILE_URI = "/_attaches/gwsub/sb05_requests"
  FILE_DIR = "#{Rails.root.to_s}/public#{FILE_URI}"
  UP_DIR = "#{Rails.root.to_s}/upload/#{FILE_URI}"

  #----------------------------------------------------------------------------
  #
  def item_path
    return "/gwsub/sb05/?title_id=#{self.title_id}&p_id=#{self.parent_id}"
  end
  #
  def delete_path
    return "/gwsub/sb05/#{self.id}/delete?title_id=#{self.title_id}&p_id=#{self.parent_id}"
  end
  #----------------------------------------------------------------------------

  def parent_name #親記事Docsのnameフィールド値相当
    return Util::CheckDigit.check(format('%07d', self.parent_id))
  end
  #
  def filepath
    str = sprintf("%08d",self.id)
    str = "#{str[0..3]}/#{str[4..7]}"
    return "#{FILE_DIR}/#{sprintf('%06d',self.parent_id)}/#{str}/"
  end
  #content_id=2は実ファイルをアクセス制御付きで管理する
  def f_path
    str = sprintf("%08d",self.id)
    str = "#{str[0..3]}/#{str[4..7]}"
    s_path = ""
    if self.content_id  == 2
      s_path = "#{UP_DIR}"
    else
      s_path = "#{FILE_DIR}"
    end
    return "#{s_path}/#{sprintf('%06d',self.parent_id)}/#{str}/"
  end
  #content_id=2は実ファイルをアクセス制御付きで管理する
  def f_name
    if self.content_id  == 2
      return "#{f_path}#{sprintf("%08d",self.id)}.dat"
    else
      return "#{filepath}#{self.filename}"
    end
  end
  #
  def _upload_file(file)
    @tmp = file
  end
  #
  def file_uri(parent_id)
    #実ファイルをアクセス制御付きで管理
    unless self.content_id  == 1
      return "/_admin/gwsub/receipts/#{self.id}/download_object?parent_id=#{parent_id}"
    else
      str = sprintf("%08d",self.id)
      str = "#{str[0..3]}/#{str[4..7]}"
      return "#{FILE_URI}/#{sprintf('%06d',parent_id)}/#{str}/#{URI.encode(self.filename)}"
    end
  end

  #実ファイルを保存
  def after_create
    if self.db_file_id == 0
      FileUtils.mkdir_p(f_path) unless FileTest.exist?(f_path)
      File.open(f_name, "wb") { |f|
        f.write @tmp.read
      }
    end
  end

  #実ファイル保存の時は
  #1フォルダ1ファイルの仕様なので、フォルダごと削除
  def after_destroy
    if self.db_file_id == 0
      #http://www.namaraii.com/rubytips/?%A5%C7%A5%A3%A5%EC%A5%AF%A5%C8%A5%EA
      # サブディレクトリを階層が深い順にソートした配列を作成
      dirlist = Dir::glob(f_path + "**/").sort {
        |a,b| b.split('/').size <=> a.split('/').size
      }
      begin
      # サブディレクトリ配下の全ファイルを削除後、サブディレクトリを削除
      dirlist.each {|d|
        Dir::foreach(d) {|f|
        File::delete(d+f) if ! (/\.+$/ =~ f)
        }
        Dir::rmdir(d)
      }
      rescue
      end
    end
  end
  #----------------------------------------------------------------------------

end
