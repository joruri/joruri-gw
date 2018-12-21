class UpdateSendToAndSendToKindOnQuestionnaireBases < ActiveRecord::Migration
  def up
    execute "update questionnaire_bases set send_to = 0"
    execute "update questionnaire_bases set send_to_kind = 0"
  end

  def down
  end
end
