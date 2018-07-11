class AddSendToAndSendToKindToQuestionnaireBases < ActiveRecord::Migration
  def change
    add_column :questionnaire_bases, :send_to, :integer, :after => :remarks_setting
    add_column :questionnaire_bases, :send_to_kind, :integer, :after => :send_to
  end
end
