module Concerns::Gwworkflow::Doc::Step
  extend ActiveSupport::Concern

  def rebuild_steps_and_committees(uids)
    steps.each(&:mark_for_destruction)
    if uids.present?
      uids.each_with_index do |uid, idx|
        build_step_for_committee(uid, idx)
      end
    end
  end

  def rebuild_future_steps_and_committees(uids)
    future_steps.each(&:mark_for_destruction)
    if uids.present?
      uids.each_with_index do |uid, idx|
        build_step_for_committee(uid, current_number + idx + 1)
      end
    end
  end

  private

  def build_step_for_committee(uid, idx)
    if user = System::User.find_by(id: uid)
      step = steps.build(number: idx)
      step.committees.build(state: 'undecided', comment: '', 
        user_id: user.id, user_name: user.name, user_gname: user.group_name)
    end
  end
end
