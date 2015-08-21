class ArchiveStateMachine
  include Statesman::Machine

  state :pending, initial: true
  state :generating
  state :ready
  state :failed

  transition from: :pending,    to: :generating
  transition from: :generating, to: [:ready, :failed]
  transition from: :ready,      to: [:generating, :pending]
  transition from: :failed,     to: :generating
end
