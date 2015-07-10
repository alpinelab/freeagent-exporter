require 'csv'

class Archive < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordQueries

  belongs_to :bank_account
  has_many   :archive_transitions

  validates_presence_of :bank_account, :year
  validates_uniqueness_of :month, scope: [:bank_account, :year]

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state, :last_transition, :history, :allowed_transitions, to: :state_machine

  def start_date
    Date.new(year, month, 01)
  end

  def end_date
    start_date.at_end_of_month
  end

  def state_machine
    @state_machine ||= ArchiveStateMachine.new(self, transition_class: ArchiveTransition)
  end

  def to_csv
    bank_transactions = FreeAgent::BankTransaction.find_all_by_bank_account(
      bank_account.freeagent_id,
      { from_date: start_date, to_date: end_date }
    )
    CSV.generate do |csv|
      bank_transactions.each do |bank_transaction|
        csv << [bank_transaction.id, "#{bank_transaction.id}-foo.png"]
      end
    end

  end
end
