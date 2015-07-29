# -*- encoding: utf-8 -*-

# 対象データベースは ****_jgw_gw なので Gw::Database を継承
class Gwworkflow::Doc < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Cms::Model::Base::Content
  include Gwboard::Model::Recognition
  include Gwworkflow::Model::Systemname
  # テーブル名を明示的に指定
  set_table_name 'gw_workflow_docs'
  
  
  has_many :steps, :class_name => 'Gwworkflow::Step', :foreign_key => :doc_id,
    :dependent => :destroy

  validates :title, :presence => true, :length => { :maximum => 140 }
    
  validates :expired_at, :presence => true

  validate :date_valid?
  def date_valid?
      # errors.add('期限日', 'は現在よりも後に設定してください。') if expired_at <= DateTime.now
  end
  validate :committees_valid?
  def committees_valid?
    errors.add('承認ステップ', 'を少なくとも1つ設定してください。') if steps.length == 0
  end
  
  after_validation :delete_route
  def delete_route
    if errors.size > 0
      steps.each{|s|s.destroy}
    end
  end
  
  # 条件を指定して取得
  scope :find_by_conditions, ->(options={}){
    filter = options[:filter] ? options[:filter].to_sym : :all
    type = options[:type] ? options[:type].to_sym : :committed
    state = options[:state] ? options[:state].to_sym : :all
    offset = options[:offset] ? options[:offset].to_i : 0
    limit = options[:limit] ? options[:limit].to_i : 20

    sts = case type
      when :committed then [:draft, :accepted, :rejected, :remanded, :applying]
      when :processing then [:applying] 
      when :accepted then [:accepted, :rejected, :remanded, :applying]
      else [] # これら以外で表示するもの
      end
      
    docs = case type
    when :committed
      where(arel_table[:creater_id].eq(Site.user.id))
    when :processing
      all.select{|doc|
        cs = doc.current_step
        cs ? cs.committee.user_id == Site.user.id : false
      }
    when :accepted
      all.select{|doc|
        doc.steps.any?{|step|
          (step.committee.user_id == Site.user.id) && (step.committee.state == 'accepted')
        }
      }
    else []
    end
    docs = docs.select{|doc| sts.any?{|s| doc.real_state == s} }
      .select{|doc| filter == :all || doc.real_state == filter}
  }
  
  
  def real_state
    if state.to_sym == :applying
       return :accepted if steps.all?{|step| step.state == :accepted }
       return :rejected if steps.any?{|step| step.state == :rejected }
       return :remanded if steps.any?{|step| step.state == :remanded }
    else
    end
    return state.to_sym
  end
  def sorted_steps
    steps.sort{|a,b|a.number <=> b.number}
  end
  
  def total_steps
    steps.length
  end
  
  def now_step
    s = current_step
    s ? s.number : total_steps
  end
  def current_step
    sorted_steps.detect{|step| step.state.to_sym != :accepted }
    #raise sorted_steps.map{|s| "#{s.committee.user_name}-#{s.state.to_s}-#{s.number.to_s}; " }.to_s
  end
  
  def fixed_steps
    sorted_steps.select{|step| step.accepted? }
  end
  
  def future_steps
    sorted_steps.select{|step| step.number > current_step.number }
  end
  
  def fixed_committees
    fixed_steps.map{|step| step.committee }
  end
  
  def future_committees
    future_steps.map{|step| step.committee }
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

end
