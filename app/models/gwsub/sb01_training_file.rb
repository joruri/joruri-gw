# -*- encoding: utf-8 -*-
class Gwsub::Sb01TrainingFile < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content
  include Gwsub::Model::AttachFile
  include Cms::Model::Base::Content
  
#  belongs_to :status, :foreign_key => :state,     :class_name => 'Sys::Base::Status'
  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'Gwsub::Sb01Training'

  validates_presence_of :filename, :message => "ファイルが指定されていません。"

  FILE_URI = "/_attaches/gwsub/sb01_training"
  FILE_DIR = "#{Rails.root}/public#{FILE_URI}"
  UP_DIR = "#{Rails.root}/upload/#{FILE_URI}"

	#mysqlの int max = 2147483647
	KARI_ID_START = 2000000000
	KARI_ID_END = 2147483647
	KARI_ID_RANGE = KARI_ID_END - KARI_ID_START
	def self.create_kari_id()
		return KARI_ID_START + rand(KARI_ID_RANGE)
	end

	#研修申し込み用に作成中の研修企画に添付された仮IDのままのファイルの一覧を取得する
	def self.get_abandoned_files(created_at)
			return self.where("parent_id >= #{KARI_ID_START} and created_at < '#{created_at}'")
	end

	#研修レコードと添付ファイルを削除する
	def delete_record()
		self.delete_attached_folder
		self.delete
	end

  #検索用
  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 'kwd'
        search_keyword v, :filename
      end
    end if params.size != 0

    return self
  end

  #----------------------------------------------------------------------------
  def item_path
    return "#{Site.current_node.public_uri.chop}&p_id=#{self.parent_id}"
  end
  #
  def edit_memo_path
    return "#{Site.current_node.public_uri}#{self.parent_id}/edit_file_memo/#{self.id}"
  end
  #
  def item_parent_path
    return "#{Site.current_node.public_uri}#{self.parent_id}"
  end
  #
  def item_doc_path(item)
    return "#{Site.current_node.public_uri}#{self.parent_id}"
  end
  #
  def delete_path
    return "#{Site.current_node.public_uri}#{self.id}/delete&p_id=#{self.parent_id}"
  end
  #----------------------------------------------------------------------------

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

  #1フォルダ1ファイルの仕様なので、フォルダごと削除
  def after_destroy
    if self.db_file_id == 0
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

  #親フォルダをリネームする
  def move_parent_path(dest_parent_id)
    current_path = self.f_name
    
    #現在の親フォルダ名でパスを分割する
    kami, shimo = current_path.split(/\/#{parent_id}\//)
    dest_folder_name = sprintf("%06d", dest_parent_id)
    
    cur_path = kami + '/' + parent_id.to_s
    new_path = kami + '/' + dest_folder_name
    
    #現在のフォルダがあり、リネーム先のフォルダがない場合に処理する
    if FileTest.exist?(cur_path) == true && FileTest.exist?(new_path) == false
      File::rename(cur_path, new_path) 
      return true
    end
    
    return false
  end
 
  #親フォルダの書式
  def parent_folder_form(id)
    return sprintf("%06d",id)
  end

  #親フォルダ名を返す
  def parent_folder_name
    return parent_folder_form(self.parent_id)
  end


  #その添付ファイルの保管場所を削除する
  def delete_attached_folder
    deleteall(self.parent_path) if FileTest.exist?(self.parent_path)
  end
  
  #その添付ファイルの保管場所を返す
  #例)/var/share/jorurigw/public/_attaches/gwsub/sb01_training/000000
  def parent_path
    return "#{self.s_path}/#{self.parent_folder_name}"
  end

  def s_path
    if self.content_id  == 2
      s_path = "#{UP_DIR}"
    else
      s_path = "#{FILE_DIR}"
    end
    return s_path
  end
  
  
  #----------------------------------------------------------------------------
end
