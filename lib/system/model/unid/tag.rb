# encoding: utf-8
module System::Model::Unid::Tag
  def self.included(mod)
    mod.has_many :tags, :primary_key => 'unid', :foreign_key => 'unid', :class_name => 'System::Tag',
      :dependent => :destroy

    mod.after_save :save_tags
  end

  attr_accessor :_tags

  def find_tag_by_name(name)
    return nil if tags.size == 0
    tags.each do |tag|
      return tag.word if tag.name == name
    end
    return nil
  end

  def save_tags
    return true  unless _tags
    return false unless unid
    return false if @save_tags_callback_flag

    @save_tags_callback_flag = true

    _tags.each do |k, word|
      name  = k.to_s

      if word == ''
        tags.each do |tag|
          tag.destroy if tag.name == name
        end
      else
        items = []
        tags.each do |tag|
          if tag.name == name
            items << tag
          end
        end

        if items.size > 1
          items.each {|tag| tag.destroy}
          items = []
        end

        if items.size == 0
          tag = System::Tag.new({:unid => unid, :name => name, :word => word})
          tag.save
        else
          items[0].word = word
          items[0].save
        end
      end
    end

    tags(true)
    return true
  end
end