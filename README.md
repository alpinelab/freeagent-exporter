# FreeAgent Exporter

[![Build Status](https://semaphoreci.com/api/v1/projects/0e55d82b-5241-401b-9ee1-5594093b71a5/425544/shields_badge.svg)](https://semaphoreci.com/michaelbaudino/freeagent-exporter)
[![Code Climate](https://codeclimate.com/github/alpinelab/freeagent-exporter/badges/gpa.svg?style=flat-square)](https://codeclimate.com/github/alpinelab/freeagent-exporter)
[![Test Coverage](https://codeclimate.com/github/alpinelab/freeagent-exporter/badges/coverage.svg)](https://codeclimate.com/github/alpinelab/freeagent-exporter/coverage)

Freeagent Exporter conects to your FreeAgent account and lets you download monthly zip archives of all you attached documents.

## Supported documents

- [x] Bank transaction explainations
- [ ] Bills
- [x] Expenses
- [ ] Invoices

## Recording API responses for stubbing

Example to stub `FreeAgent::BankAccount.all`:
```
curl -is -H 'Authorization: Bearer FREEAGENT_ACCESS_TOKEN' -H 'Accept: application/json' -H 'Content-Type: application/json' -H 'User-Agent: freeagent-api-rb' "https://api.sandbox.freeagent.com/v2/bank_accounts" > spec/api_responses/bank_account_all.json.http
```

Then, in the spec:
```
stub_request(:get, Regexp.new("https://api.sandbox.freeagent.com/v2/bank_accounts.*")).
  to_return(File.new('spec/api_responses/bank_account_all.json.http'))
```

## License

Released under the MIT license, see `LICENSE.md` for full license text
