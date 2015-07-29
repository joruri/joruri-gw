# -*- encoding: utf-8 -*-
module Cms::Model::Base::Content
  def states
    {'draft' => '下書き保存', 'recognize' => '承認待ち'}
  end

  def readable
    join_creator
    self.and "system_creators.group_id", Site.user_group.id
    return self
  end

  def editable
    join_creator
    self.and "system_creators.group_id", Site.user_group.id
    return self
  end

  def deletable
    join_creator
    self.and "system_creators.group_id", Site.user_group.id
    return self
  end

  def public
    self.and "published_at", 'IS NOT', nil if Site.mode != 'preview'
    return self
  end

  def readable?
    return true
  end

  def creatable?
    return true
  end

  def editable?
    return true
  end

  def deletable?
    return true
  end

  def public?
    return true if Site.mode == 'preview'
    return published_at != nil
  end

  def search_forward(keyword, *columns)
    search_keyword(keyword, columns, :forward=>1)
  end
  def search_backward(keyword, *columns)
    search_keyword(keyword, columns, :backward=>1)
  end
  def search_equal(keyword, *columns)
    search_keyword(keyword, columns, :equal=>1)
  end
  def search_keyword(keyword, *columns)
    ret_a = search_keyword_core(keyword, columns)
    condition = Condition.new()
    condition.and do |cond|
      ret_a.each do |x|
        cond.or x[0], 'like', x[1]
      end
    end
    self.and condition
    return self
  end

  def and_keywords(words, *columns)
    and_keywords2(words, *columns)
  end

  def and_keywords2(words, *columns)
    cond = Condition.new
    words.to_s.split(/[ 　]+/).each_with_index do |w, i|
      break if i >= 10
      cond.and do |c|
        columns.each do |col|
          qw = connection.quote_string(w).gsub(/([_%])/, '\\\\\1')
          c.or col, 'LIKE', "%#{qw}%"
        end
      end
    end
    self.and cond
    self
  end

  def search_keyword_where(keyword, *columns)
    return search_keyword_core(keyword, columns).collect{|x| "(#{x[0]} like #{x[1]})"}.join(" or ")
  end

  def search_keyword_core(keyword, columns)
    options = {}
    if columns.last.is_a? Hash
      options = columns.last
      columns.pop
    end

    ret_a = []
    keyword.split(/[ 　]+/).each_with_index do |w, i|
      break if i >= 10
      columns.each do |col|
        w1 = w.to_s
          w1 = connection.quote_string(w).gsub(/([_%])/, '\\\\\1')
          case
          when !options[:forward].nil?
            ret_a.push [col, "#{w1}%"]
          when !options[:backward].nil?
            ret_a.push [col, "%#{w1}"]
          when !options[:equal].nil?
            ret_a.push [col, "#{w1}"]
          else
            ret_a.push [col, "%#{w1}%"]
          end
      end
    end
    return ret_a
  end

  def search_id(key_value, column)
    condition = Condition.new()
    condition.and do |cond|
      w1 = key_value.to_s
      cond.or column, '=', "#{w1.to_i}"
    end
    self.and condition
    return self
  end

  def search_id2(key_value, *columns)
    condition = Condition.new()
    condition.and do |cond|
      columns.each do |column|
        w1 = key_value.to_s
        cond.or column, '=', "#{w1.to_i}"
      end
    end
    self.and condition
    return self
  end

  def search_state(key_value, column)
    condition = Condition.new()
    condition.and do |cond|
      w1 = key_value.to_s
      cond.or column, '=', "'#{w1}'"
    end
    self.and condition
    return self
  end

  def bread_crumbs(crumbs, options = {})
    return crumbs
  end
end