class Gwsub::Sb06BudgetAssign < Gwsub::GwsubPref
  include System::Model::Base
  include System::Model::Base::Content

  belongs_to :grp1        ,:foreign_key=>:group_id                ,:class_name => 'System::GroupHistory'
  belongs_to :grp2        ,:foreign_key=>:multi_group_id          ,:class_name => 'System::GroupHistory'
  belongs_to :grp_p1      ,:foreign_key=>:group_parent_id         ,:class_name => 'System::GroupHistory'
  belongs_to :grp_p2      ,:foreign_key=>:multi_group_parent_id   ,:class_name => 'System::GroupHistory'
  belongs_to :user        ,:foreign_key=>:user_id                 ,:class_name => 'System::User'
  belongs_to :b_role      ,:foreign_key=>:budget_role_id          ,:class_name => 'Gwsub::Sb06BudgetRole'

  before_validation :before_validates_setting_columns
  # 必須項目は、必ず設定させるため、チェックしない
#  validates_presence_of :group_id,:user_id,:budget_role_id
  validate :validate_each_columns_on_create
  validate :validate_each_columns_on_update

  before_create :before_create_setting_columns
  before_update :before_update_setting_columns

  def before_create_setting_columns
    Gwsub.gwsub_set_creators(self)
    Gwsub.gwsub_set_editors(self)
  end
  def before_update_setting_columns
    Gwsub.gwsub_set_editors(self)
  end

  def before_validates_setting_columns
#  end
#
#  def before_save_setting_columns
    # id=>code/name
    # 所属・上位所属
    unless self.group_id.to_i==0
      self.group_code       = self.grp1.code
      self.group_name       = self.grp1.name
      self.group_ou         = self.group_code+self.group_name
      if self.group_parent_id.to_i==0
        self.group_parent_id  = self.grp1.parent_id
        self.group_parent_code = self.grp_p1.code
        self.group_parent_name = self.grp_p1.name
        self.group_parent_ou   = self.group_parent_code + self.group_parent_name
      else
        self.group_parent_code = self.grp_p1.code
        self.group_parent_name = self.grp_p1.name
        self.group_parent_ou   = self.group_parent_code + self.group_parent_name
      end
    end
    # 職員番号
    unless self.user_id.to_i==0
      self.user_code     = self.user.code
      self.user_name     = self.user.name
    end
    # 権限
    unless self.budget_role_id.to_i==0
      self.budget_role_code    = self.b_role.code
      self.budget_role_name    = self.b_role.name
    end
    # 兼務所属
    if self.multi_group_id.to_i==0
      # 指定が無ければ自所属
        self.multi_group_id      = self.group_id
        self.multi_group_code    = self.group_code
        self.multi_group_name    = self.group_name
        self.multi_group_ou      = self.group_code+self.group_name
        self.multi_user_code     = self.user_code
    else
      # 指定があれば指定値
        self.multi_group_code    = self.grp2.code
        self.multi_group_name    = self.grp2.name
        self.multi_group_ou      = self.multi_group_code+self.multi_group_name
    end
    # 兼務所属の上位所属
    unless self.multi_group_id.to_i==0
        self.multi_group_parent_id    = self.grp2.parent_id
        self.multi_group_parent_code  = self.grp_p2.code
        self.multi_group_parent_name  = self.grp_p2.name
        self.multi_group_parent_ou    = self.multi_group_parent_code+self.multi_group_parent_name
    end
    # ログインユーザーコード
    if  self.multi_sequence.blank?
        self.multi_user_code     = self.user_code
    else
        multi_user_code          = self.user_code
        multi_user_code2         = multi_user_code.slice(0,multi_user_code.size-1)
        self.multi_user_code     = multi_user_code2+self.multi_sequence
    end
  end

  def self.sb06_budget_assign_id_select(options={})
    order = "section_kind_code,group_code,user_code ASC"
    item = Gwsub::Sb06BudgetAssign.new
    items = item.find(:all,:order=>order)
    selects = []
    items.each do |g|
      selects << ['('+g.user_code+')'+g.user_name ,g.id]
    end
    return selects
  end

  def self.grouplist(options={})
#pp options
    # options
    # :group_id => 絞り込み対象グループ
    # :date   => 対象日
    # :role1  =>  管理者権限
    # :role2  =>  主管課権限
    # :all    => 'all' 選択肢に「すべて」を含む
    #
    # (1) 管理者は全所属対象
    if options[:role1]==true
      groups  = Gwsub.grouplist4( nil ,options[:all] , true , nil)
      return groups
    end
    # (2) 主管課は親所属共通を対象
    if options[:role2]==true
      parent_id = Core.user_group.parent_id
      g1 = System::GroupHistory.new
      g1.parent_id = parent_id
      groups = g1.find(:all)
      group_select = []
      return group_select << ['対象なし',0]if groups.blank?
      group_select << ['すべて',0] if options[:all]=='all'
      groups.each do |g|
        group_select << ['('+g.code.to_s+')'+g.name.to_s,g.id]
      end
      return group_select
    end
    # (3) 一般は自所属のみ
    group_select = []
    groups = System::GroupHistory.find(Core.user_group.id)
    return group_select << ['対象なし',0]if groups.blank?
#    group_select << ['すべて',0] if options[:all]=='all'
#    groups.each do |g|
      group_select << ['('+groups.code.to_s+')'+groups.name.to_s,groups.id]
#    end
    return group_select
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_keyword'
        search_keyword v,:group_code,:group_name,:user_code,:user_name,:multi_group_code,:multi_group_name,:budget_role_name
      when 'b_role_id'
        search_id v,:budget_role_id unless v.to_i==0
      when 'group_parent_id'
        search_id v,:group_parent_id unless v.to_i==0
      when 'group_id'
        search_id v,:group_id unless v.to_i==0
      when 'multi_group_id'
        search_id v,:multi_group_id unless v.to_i==0
      when 'm_state'
        search_id v,:main_state unless v.to_i==0
      when 'a_state'
        search_id v,:admin_state unless v.to_i==0
      end
    end if params.size != 0

    return self
  end

  private
  def validate_each_columns_on_create
    # 新規登録時のチェック内容
    #   ユーザー・兼務所属内で権限(budget_role_id)重複不可
    #     →権限登録済
    # 　ユーザーログインコード(multi_user_code)重複不可
    # 　　→兼務順指定の間違い（未入力・または重複）
    # 　兼務順は半角英小文字
    return true unless self.id.blank?

    valid  = true
    #   ユーザー・同一兼務所属では権限重複不可
      user_cond = "user_id=#{self.user_id} and multi_group_id=#{self.multi_group_id} and budget_role_id=#{self.budget_role_id}"
      user_count  = Gwsub::Sb06BudgetAssign.where(user_cond).count
      if user_count > 0
        errors.add :budget_role_id, 'は登録済です。'
        valid = false
        return valid
      end
    #   ユーザーログインコード(multi_user_code)重複不可
      login_cond = "multi_user_code='#{self.multi_user_code}'"
      login_count  = Gwsub::Sb06BudgetAssign.where(login_cond).count
      if login_count > 0
        # ログイン重複
        if self.group_id  ==  self.multi_group_id
          # 兼務なし
          if self.multi_sequence.blank?
            errors.add :multi_sequence, 'を入力してください。'
          else
            errors.add :multi_sequence, 'は登録済です。別の値を入力してください。'
          end
        else
          # 兼務あり
          if self.multi_sequence.blank?
            errors.add :multi_sequence, 'を入力してください。'
          else
            errors.add :multi_sequence, 'は登録済です。別の値を入力してください。'
          end
        end
        valid = false
        return valid
      else
        # logijn_count==0はエラーではない
      end
    # 　兼務順は半角英小文字
      if self.multi_sequence.blank?
      else
        if /\A[a-z]\Z/  =~ self.multi_sequence
        else
          errors.add :multi_sequence, 'は、半角英小文字１文字で入力してください。'
          valid = false
          return valid
        end
      end
    # true で戻る
    return valid
  end
  def validate_each_columns_on_update
    # 編集登録時のチェック内容
    #   ユーザー・兼務所属内で権限(budget_role_id)重複不可
    #     →権限登録済
    # 　ユーザーログインコード(multi_user_code)重複不可
    # 　　→兼務順指定の間違い（未入力・または重複）
    # 　兼務順は半角英小文字

    return true if self.id.blank?

    valid  = true
    #   ユーザー・同一兼務所属では権限重複不可
      user_cond = "user_id=#{self.user_id} and multi_group_id=#{self.multi_group_id} and budget_role_id=#{self.budget_role_id}"
      user_count  = Gwsub::Sb06BudgetAssign.where(user_cond).count
      if self.budget_role_id_changed?
        # 入力値を変更→編集前の自分自身がない→変更先で重複
        if user_count > 0
          errors.add :budget_role_id, 'は登録済です。'
          valid = false
          return valid
        end
      else
        # 入力変更なし→編集前の自分自身がある
        if user_count > 1
          errors.add :budget_role_id, 'は登録済です。'
          valid = false
          return valid
        end
      end
    #   ユーザーログインコード(multi_user_code)重複不可
      login_cond = "multi_user_code='#{self.multi_user_code}'"
      login_count  = Gwsub::Sb06BudgetAssign.where(login_cond).count
      if self.multi_user_code_changed?
        # ログインコードが変更されている
        if login_count > 0
          # 変更後に重複
          if self.group_id  ==  self.multi_group_id
            # 兼務なし
            if user_count==0
              # 担当未登録
              if self.multi_sequence.blank?
                errors.add :multi_sequence, 'を入力してください。'
              else
                errors.add :multi_sequence, 'は登録済です。別の値を入力してください。'
              end
            else
              # 担当者重複
              errors.add :user_id, 'は登録済です。'
            end
          else
            # 兼務あり
            if user_count==0
              # 担当未登録
              if self.multi_sequence.blank?
                errors.add :multi_sequence, 'を入力してください。'
              else
                errors.add :multi_sequence, 'は登録済です。別の値を入力してください。'
              end
            else
              # 担当者重複
              errors.add :user_id, 'は登録済です。'
            end
          end
          valid = false
          return valid
        else
          # login_count==0はエラーではない
        end
      else
        # ログインコードが変更されていない→自分自身が存在する
        if login_count > 1
          if self.group_id  ==  self.multi_group_id
            # 兼務なし
            if user_count==0
              # 担当未登録
              if self.multi_sequence.blank?
                errors.add :multi_sequence, 'を入力してください。'
              else
                errors.add :multi_sequence, 'は登録済です。別の値を入力してください。'
              end
            else
              # 担当者重複
              errors.add :user_id, 'は登録済です。'
            end
          else
            # 兼務あり
            if user_count==0
              # 担当者重複
              if self.multi_sequence.blank?
                errors.add :multi_sequence, 'を入力してください。'
              else
                errors.add :multi_sequence, 'は登録済です。別の値を入力してください。'
              end
            else
              # 担当者重複
              errors.add :user_id, 'は登録済です。'
            end
          end
          valid = false
          return valid
        else
          # login_count==1はエラーではない
        end
      end
    # 　兼務順は半角英小文字
      if self.multi_sequence.blank?
        if self.multi_group_id != self.group_id
          errors.add :multi_sequence, 'を入力してください。'
          valid = false
          return valid
        end
      else
        if /\A[a-z]\Z/  =~ self.multi_sequence
        else
          errors.add :multi_sequence, 'は、半角英小文字１文字で入力してください。'
          valid = false
          return valid
        end
      end
    # true で戻る
    return valid
  end
end
