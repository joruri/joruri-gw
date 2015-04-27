module System::Model::Base::Content
  def states
    {'public' => '公開', 'closed' => '非公開'}
  end

  def readable?
    true
  end

  def creatable?
    true
  end

  def editable?
    true
  end

  def deletable?
    true
  end

  def public?
    true
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
          qw = self.class.connection.quote_string(w).gsub(/([_%])/, '\\\\\1')
          c.or col, 'LIKE', "%#{qw}%"
        end
      end
    end
    self.and cond
    self
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
          w1 = self.class.connection.quote_string(w).gsub(/([_%])/, '\\\\\1')
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
end