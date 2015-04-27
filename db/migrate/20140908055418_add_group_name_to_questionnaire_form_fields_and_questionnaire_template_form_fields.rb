class AddGroupNameToQuestionnaireFormFieldsAndQuestionnaireTemplateFormFields < ActiveRecord::Migration
  def change
    add_column :questionnaire_form_fields, :group_name, :text
    add_column :questionnaire_template_form_fields, :group_name, :text
  end
end
