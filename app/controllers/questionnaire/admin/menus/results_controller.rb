# -*- encoding: utf-8 -*-
################################################################################
#
################################################################################
class Questionnaire::Admin::Menus::ResultsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Questionnaire::Model::Database
  include Questionnaire::Model::Systemname
  layout "admin/template/portal_1column"

  def initialize_scaffold
    @css = ["/_common/themes/gw/css/circular.css"]
    @system_title = 'アンケート集計システム'
    Page.title = @system_title
    params[:limit] = 100

    @title = Questionnaire::Base.find_by_id(params[:parent_id])
    return http_error(404) unless @title
    return http_error(404) if @title.form_body.blank?
    @field_lists = JsonParser.new.parse(@title.form_body_json)
    return http_error(404) if @field_lists.size == 0
  end

  def is_creator
    system_admin_flags
    params[:cond] = '' if @title.creater_id == Site.user.code if @is_sysadm
    params[:cond] = 'admin' unless @title.creater_id == Site.user.code if @is_sysadm

    ret = false
    ret = true if @is_sysadm
    ret = true if @title.creater_id == Site.user.code  if @title.admin_setting == 0
    ret = true if @title.section_code == Site.user_group.code  if @title.admin_setting == 1
    @is_creator = ret
    return ret
  end

  def index
    is_not_open_public = true
    is_not_open_public = false if @title.result_open_state == true if @title.state == 'closed'
    is_creator
    return authentication_error(403) unless @is_creator if is_not_open_public
    #非公開
    if @title.include_index == false
      return http_error(404) if params[:k].blank?
      return http_error(404) unless params[:k].to_s == @title.keycode
    end unless @is_sysadm

    item = Questionnaire::Result.new
    item.and :title_id, @title.id
    item.order "sort_no, field_id, option_id"
    @items = item.find(:all)
  end


  def answer_to_details
    return authentication_error(403) unless is_creator
    params_key_code = ''
    params_key_code = "?k=#{@title.keycode}" if @title.include_index == false

    sql = Condition.new
    #グループ化しない通常パーツ
    sql.or {|d|
      d.and :state, 'public'
      d.and :parent_id , @title.id
      d.and :group_code, 'is', nil
    }
    #グループ親設定
    sql.or {|d|
      d.and :state, 'public'
      d.and :question_type, 'group'
      d.and :parent_id, @title.id
    }
    field_count = Questionnaire::FormField.count(:conditions=>sql.where)
    Questionnaire::Result.destroy_all("title_id=#{@title.id}")
    Questionnaire::Temporary.destroy_all("title_id=#{@title.id}")
    field_to_result_records(field_count)
    item = Enquete::Answer.new
    item.and :state, 'public'
    item.and :title_id, @title.id
    answers = item.find(:all)
    return redirect_to "/questionnaire/#{@title.id}/results#{params_key_code}" if answers.blank?

    for answer in answers
      for i in 1..field_count
        field = "field_#{sprintf('%03d',i)}"
        next if answer[field].blank?

        fld = @field_lists[i-1]

        create_temporary_record(fld, answer[field]) if fld['field_name'] == field
      end
    end

    return redirect_to "/questionnaire/#{@title.id}/results#{params_key_code}" if @title.state == 'draft'

    total_answer_update
    calculate_the_percentage
    redirect_to "/questionnaire/#{@title.id}/results#{params_key_code}"
  end
  #-->
  #設問
  def field_to_result_records(field_count)
    for i in 1..field_count
      fld = @field_lists[i-1]

      options = ''
      if fld['question_type'].index('text').blank?
        item = Questionnaire::FormField.find_by_id(fld['field_id'])
        options = JsonParser.new.parse(item.option_body_json) unless item.option_body.blank? unless item.blank?
      end

      item = Questionnaire::Result.new
      item.and :title_id, @title.id
      item.and :field_id, fld['field_id']
      result = item.find(:first)
      if result.blank?
        if options.blank?
          create_result_text_record(i, fld)
        else
          create_result_option_records(i, fld, options)
        end
      end
    end
  end
  #
  def create_result_text_record(i, fld)
    Questionnaire::Result.create({
      :state => 'public' ,
      :title_id => @title.id ,
      :field_id => fld['field_id'] ,
      :question_type => fld['question_type'] ,
      :question_label => fld['title'] ,
      :option_id => 0 ,
      :sort_no => i ,
      :answer_count => 0 ,
      :answer_ratio => 0.0
    })
  end
  def create_result_option_records(i, fld, options)
    for option in options
      if fld['question_type'] == 'select'
        option_id = option[1]
        option_label = option[0]
      else
        option_id = option['value']
        option_label = option['title']
      end
      unless option_id == 0
        Questionnaire::Result.create({
          :state => 'public' ,
          :title_id => @title.id ,
          :field_id => fld['field_id'] ,
          :question_type => fld['question_type'] ,
          :question_label => fld['title'] ,
          :option_id => option_id ,
          :option_label => option_label ,
          :sort_no => i ,
          :answer_count => 0 ,
          :answer_ratio => 0.0
        })
      end unless option_id.blank?
    end
  end
  #<--

  #回答集計用
  #-->
  def create_temporary_record(fld, answer)
    is_text = false
    is_text = true if fld['question_type'].index('text')
    is_text = true if fld['question_type'] == 'group'
    #text系
    if is_text
      Questionnaire::Temporary.create({
        :title_id => @title.id ,
        :field_id => fld['field_id'] ,
        :question_type => fld['question_type'] ,
        :answer_text => answer,
        :answer_option => 0
      })
    else
      if fld['question_type'] == 'select'
        Questionnaire::Temporary.create({
          :title_id => @title.id ,
          :field_id => fld['field_id'] ,
          :question_type => fld['question_type'] ,
          :answer_text => '',
          :answer_option => answer
        })
      else
        values = []
        values = JsonParser.new.parse(answer) unless answer.blank?
        for value in values
          Questionnaire::Temporary.create({
            :title_id => @title.id ,
            :field_id => fld['field_id'] ,
            :question_type => fld['question_type'] ,
            :answer_text => '',
            :answer_option => value
          })
        end
      end
    end
  end
  #<--
  #
  def total_answer_update
    sql = "SELECT title_id,field_id,question_type,answer_text,answer_option,COUNT(id) AS cnt FROM `questionnaire_temporaries`"
    sql = "#{sql} WHERE title_id=#{@title.id}"
    sql = "#{sql} GROUP BY title_id,field_id,question_type,answer_text,answer_option"
    items = Questionnaire::Temporary.find_by_sql(sql)
    return if items.blank?

    for item in items
      r_item = Questionnaire::Result.new
      r_item.and :state, 'public'
      r_item.and :title_id, @title.id
      r_item.and :field_id, item.field_id
      r_item.and :option_id, item.answer_option
      result = r_item.find(:first)
      next if result.blank?

      result.answer_count = result.answer_count + item.cnt.to_i
      result.save
    end
  end

  def calculate_the_percentage
    sql = "SELECT `title_id`, `field_id`, `question_type`, SUM(`answer_count`) AS `total_cnt` FROM `questionnaire_results`"
    sql = "#{sql} WHERE title_id = #{@title.id} AND ((`question_type`='radio') OR (`question_type`='select') OR (`question_type`='checkbox'))"
    sql = "#{sql} GROUP BY `title_id`, `field_id`, `question_type`"
    items = Questionnaire::Result.find_by_sql(sql)
    return if items.blank?

    for item in items
      next if item.total_cnt.blank?
      next if item.total_cnt == 0

      r_item = Questionnaire::Result.new
      r_item.and :state, 'public'
      r_item.and :title_id, @title.id
      r_item.and :field_id, item.field_id
      results = r_item.find(:all)
      next if results.blank?

      for result in results
        unless item.total_cnt == 0
          result.answer_ratio = 0.0
          if result.answer_count == item.total_cnt
            result.answer_ratio = 1.0
          else
            result.answer_ratio = result.answer_count.to_f / item.total_cnt.to_f unless item.total_cnt.to_f == 0
          end
          result.answer_ratio = result.answer_ratio.round(4) * 100 unless result.answer_ratio == 0
          result.save
        end
      end
    end
  end


  def result_open
    open_close_update(true)
  end
  def result_close
    open_close_update(false)
  end
  def open_close_update(state=nil)
    return authentication_error(403) unless is_creator
    return unless @title.state == 'closed'

    @title.	result_open_state = state
    unless @is_sysadm
      @title.creater_id = Site.user.code
      @title.creater = Site.user.name
      @title.createrdivision = Site.user_group.name
      @title.createrdivision_id = Site.user_group.code
    end
    @title.save
    params_key_code = ''
    params_key_code = "?k=#{@title.keycode}" if @title.include_index == false
    redirect_to "/questionnaire/#{@title.id}/results#{params_key_code}"
   end
end
