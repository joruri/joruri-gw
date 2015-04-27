module Gwboard::Model::Doc::Wiki
  extend ActiveSupport::Concern

  included do
    attr_accessor :wiki_body
    after_initialize :set_body_to_wiki_body
    before_validation :set_wiki_body_to_body
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

  def set_body_to_wiki_body
    self.wiki_body = self.body if has_attribute?(:wiki) && wiki_enabled?
  end

  def set_wiki_body_to_body
    self.body = self.wiki_body if wiki_enabled?
  end
end
