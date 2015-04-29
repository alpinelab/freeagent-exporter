class ExpensesImport
  include Sidekiq::Worker

  def perform(name, count)
    client = OAuth2::Client.new(
      ENV['FREEAGENT_ID'],
      ENV['FREEAGENT_SECRET'],
      site: ENV['FREEAGENT_URL'],
      authorize_url: '/v2/approve_app',
      token_url: '/v2/token_endpoint')
    setting = Setting.first
    if setting
      token = OAuth2::AccessToken.new(client, setting.token)

      date = (Date.today - 2.years).at_beginning_of_month
      loop do
        @bank_transactions = token.get('/v2/bank_transactions',
          :params => {
            'bank_account' => ENV['FREEAGENT_BANK_ACCOUNT_ID'],
            'from_date' => date,
            'to_date' => date.at_end_of_month
            })
        resp = JSON.parse @bank_transactions.body
        puts "#{date} got #{resp['bank_transactions'].length} bank_transactions"
        break if date > Date.today.at_end_of_month
        date = date.next_month
      end
    end
  end
end
