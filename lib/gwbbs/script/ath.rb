# -*- encoding: utf-8 -*-
class Gwbbs::Script::Ath

  def self.check
    p "開始:#{Time.now}"
    items = Gwbbs::Control.find(:all)
    for @title in items
      begin

      item = db_alias(Gwbbs::File)
      item = item.new
      files = item.find(:all)
      for file in files
        if file.content_type =~ /image/
          next unless file.width == 0
          @width = 0
          @height = 0

          begin
          f = open(file.f_name, "rb")
          r_magick(f.read)
          f.close
          rescue
          end

          item = db_alias(Gwbbs::Doc)
          doc = item.find_by_id(file.parent_id)
          state = 'NoDoc'
          state = doc.state  unless doc.blank?
          p "#{file.title_id}, #{@title.title}, #{file.parent_id}, #{state}, #{file.id}, #{file.unid}, #{file.filename}, #{file.width}, #{file.height}, '->', #{@width}, #{@height}"
          Gwbbs::Doc.remove_connection
        end
      end

      rescue
      end
      Gwbbs::File.remove_connection
    end
    p "終了:#{Time.now}"
  end

  def self.correction
    p "開始:#{Time.now}"

    items = Gwbbs::Control.find(:all)
    for @title in items
      begin

      item = db_alias(Gwbbs::File)
      item = item.new
      files = item.find(:all)
      for file in files
        if file.content_type =~ /image/
          next unless file.width == 0
          @width = 0
          @height = 0
          f = open(file.f_name, "rb")
          r_magick(f.read)
          f.close
          file.unid = 1 if file.unid == 2 #2->1
          file.width = @width
          file.height = @height
          unless @width == 0
            file.save
            p "#{file.title_id}, #{@title.title}, #{file.parent_id}, #{file.id}, #{file.unid}, #{file.filename}, #{file.width}, #{file.height}"
          end
        end
      end

      rescue
      end
      Gwbbs::File.remove_connection
    end
    p "終了:#{Time.now}"
  end

  def self.r_magick(file)
    begin
    require 'RMagick'
    image = Magick::Image.from_blob(file).shift
    if image.format =~ /(GIF|JPEG|PNG)/
      @width = image.columns
      @height = image.rows
    end
    rescue
    end
  end

  def self.db_alias(item)
    cnn = item.establish_connection
    cnn.spec.config[:database] = @title.dbname.to_s
    Gwboard::CommonDb.establish_connection(cnn.spec.config)
    return item
  end
end
