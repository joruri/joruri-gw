module Cms::Model::File
  def self.included(mod)
    mod.has_many :files, :foreign_key => 'parent_unid', :class_name => 'Cms::File',
      :primary_key => 'unid', :dependent => :destroy

    mod.after_save :upload_files
    mod.before_save :publish_files
    mod.before_save :close_files
  end

  def tmp_id
    @tmp_id || @tmp_id = Util::Sequencer.next_id('tmp_file')
  end

  def tmp_id=(id)
    @tmp_id = id
  end

  def upload_files # move to upload directory
    return true unless tmp_id

    Cms::TmpFile.find(:all, :conditions => {:tmp_id => tmp_id}).each do |tmp|
      file = Cms::File.new({
        :parent_unid  => unid,
        :name         => tmp.name,
        :title        => tmp.title,
        :mime_type    => tmp.mime_type,
        :size         => tmp.size,
        :image_is     => tmp.image_is,
        :image_width  => tmp.image_width,
        :image_height => tmp.image_height
      })
      file.skip_upload(true)
      unless file.save
        #errors.add_to_base "ファイルの保存に失敗しました (#{tmp.name})"
        next
      end

      new_dir = File::dirname(file.upload_path)
      FileUtils.mkdir_p(new_dir) unless FileTest.exist?(new_dir)

      if FileTest.exist?(tmp.upload_path)
        FileUtils.mv(tmp.upload_path, file.upload_path)
      end

      tmp_dir = File::dirname(tmp.upload_path)
      if FileTest.exist?(tmp_dir)
        Dir.rmdir(tmp_dir)
      end

      tmp.destroy
    end

    return true
  end

  def public_files_path
    File.dirname(public_path) + '/files'
  end

  def publish_files
    return true unless @save_mode == :publish

    dir = public_files_path
    FileUtils.mkdir_p(dir) unless FileTest.exist?(dir)

    files.each do |file|
      FileUtils.cp(file.upload_path, dir + '/' + file.name) if FileTest.exist?(file.upload_path)
    end
    return true
  end

  def close_files
    return true unless @save_mode == :close

    dir = public_files_path
    FileUtils.rm_r(dir) if FileTest.exist?(dir)
    return true
  end
end