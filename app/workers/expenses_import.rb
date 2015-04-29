class ExpensesImport
  include Sidekiq::Worker

  def perform(name, count)
    puts 'Doing stuff'
  end
end
