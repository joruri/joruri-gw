module Concerns::Gwworkflow::Doc::Query
  extend ActiveSupport::Concern

  included do
    scope :owner_docs, ->(user = Core.user) {
      where(creater_id: user.id).where.not(state: 'quantum')
    }
    scope :user_processing_docs, ->(user = Core.user) {
      committees = Gwworkflow::Committee.with_committee(user).with_undecided
      joins(:steps => :committees).where.not(state: ['quantum', 'draft']).merge(committees)
        .where(arel_table[:current_number].eq(Gwworkflow::Step.arel_table[:number]))
    }
    scope :user_processed_docs, ->(user = Core.user) {
      committees = Gwworkflow::Committee.with_committee(user).with_processed
      joins(:steps => :committees).where.not(state: ['quantum', 'draft']).merge(committees)
    }
    scope :search_with_params, ->(params) {
      rel = all.distinct
  
      case params[:cond]
      when 'processing'
        rel = rel.user_processing_docs(Core.user)
      when 'processed'
        rel = rel.user_processed_docs(Core.user)
      else
        rel = rel.owner_docs(Core.user)
      end
  
      rel = rel.where(state: params[:filter]) if params[:filter].present?
      rel
    }
    scope :index_order_with_params, ->(params) {
      rel = all
      if params[:sort].in?(%w(applied_at expired_at updated_at)) && params[:order].in?(%w(asc desc))
        rel = rel.order(params[:sort].to_sym => params[:order].to_sym)
      end
      rel = rel.order(id: :desc)
    }
  end
end
