module Cms::Model::Base::TmpFile
  def self.included(mod)
    mod.after_save :move_tmp_files
  end

  def tmp_id
    @tmp_id || @tmp_id = Util::Sequencer.next_id('tmp_file')
  end

  def tmp_id=(id)
    @tmp_id = id
  end

  def move_tmp_files
    return true unless tmp_id

    file_class  = eval("#{self.class}File")
    rel_column  = self.class.to_s =~ /Doc/ ? 'doc_id' : 'article_id'

    Cms::TmpFile.find(:all, :conditions => {:tmp_id => tmp_id}).each do |f|
      file = file_class.new({
        :content_id     => content_id,
        rel_column      => id,
        :name           => f.name,
        :content_type   => f.content_type,
        :content_length => f.size,
      })
      if file.save
        Util::File.put(file.upload_path, :data => '', :mkdir => true)
        FileUtils.cp(f.upload_path, file.upload_path)
      end
      f.destroy
    end

    return true
  end
end