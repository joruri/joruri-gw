class Gwworkflow::View::Doc
  attr_reader :id, :title, :state, :expired_at, :applied_at, :updated_at

  def initialize(item)
    @id = item.id
    @state = item.real_state
    @title = item.title
    @progress = {
      den: item.total_steps,
      num: item.now_step
    }
    @expired_at = item.expired_at
    @applied_at = item.applied_at
    @updated_at = item.updated_at
  end

  def progress_den # 分母
    @progress[:den]
  end

  def progress_num # 分子
    @progress[:num]
  end
  
  def state_str
    case @state.to_sym
    when :draft then '下書き'
    when :applying then '処理中'
    when :remanded then '差し戻し'
    when :accepted then '決裁'
    when :rejected then '却下'
    else '不明'
    end
  end

  def progress_str
    "(#{@progress[:num]}/#{@progress[:den]})"
  end
end
