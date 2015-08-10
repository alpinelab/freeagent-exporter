class ArchiveTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition

  belongs_to :archive, inverse_of: :archive_transitions
end
