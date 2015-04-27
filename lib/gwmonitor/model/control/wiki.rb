module Gwmonitor::Model::Control::Wiki
  extend ActiveSupport::Concern

  included do
    attr_accessor :wiki_caption
    after_initialize :set_caption_to_wiki_caption
    before_validation :set_wiki_caption_to_caption
  end

  def wiki_enabled?
    self.wiki == 1
  end

  def wiki_disabled?
    !wiki_enabled?
  end

  module ClassMethods
    def wiki_options
      [['通常', 0], ['Wiki', 1]]
    end
  end

private

  def set_caption_to_wiki_caption
    self.wiki_caption = self.caption if wiki_enabled?
  end

  def set_wiki_caption_to_caption
    self.caption = self.wiki_caption if wiki_enabled?
  end
end
