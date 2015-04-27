class ReplaceNewlineOnQuestionnaireBasesAndQuestionnaireTemplateBases < ActiveRecord::Migration
  def up
    execute 'update questionnaire_bases set form_body = replace(form_body, "\\r\\n", "\\\\r\\\\n")'
    execute 'update questionnaire_template_bases set form_body = replace(form_body, "\\r\\n", "\\\\r\\\\n")'
  end
  def down
  end
end
