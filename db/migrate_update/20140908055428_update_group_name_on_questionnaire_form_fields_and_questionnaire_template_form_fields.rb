class UpdateGroupNameOnQuestionnaireFormFieldsAndQuestionnaireTemplateFormFields < ActiveRecord::Migration
  def up
    execute "update questionnaire_form_fields set group_name = group_code"
    execute "update questionnaire_template_form_fields set group_name = group_code"
  end

  def down
  end
end
