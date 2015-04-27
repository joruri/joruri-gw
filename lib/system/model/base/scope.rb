module System::Model::Base::Scope
  extend ActiveSupport::Concern

  included do
    scope :created_before, ->(time) { where(arel_table[:created_at].lt(time)) }
    scope :created_until, ->(time) { where(arel_table[:created_at].lteq(time)) }
    scope :created_after, ->(time) { where(arel_table[:created_at].gt(time)) }
    scope :created_since, ->(time) { where(arel_table[:created_at].gteq(time)) }
    scope :search_with_text, ->(*args) {
      words = args.pop.to_s.split(/[ 　]+/)
      columns = args
      where(words.map{|w| columns.map{|c| arel_table[c].matches("%#{w.gsub(/([_%])/,'\\\\\1')}%") }.reduce(:or) }.reduce(:and))
    }
  end
end
