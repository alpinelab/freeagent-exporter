# FreeAgent Exporter

[![Build Status](https://codeship.com/projects/feae3660-3545-0133-81c0-224ef9168358/status?branch=develop)](https://codeship.com/projects/100737)
[![Code Climate](https://codeclimate.com/github/alpinelab/freeagent-exporter/badges/gpa.svg?style=flat-square)](https://codeclimate.com/github/alpinelab/freeagent-exporter)
[![Test Coverage](https://codeclimate.com/github/alpinelab/freeagent-exporter/badges/coverage.svg)](https://codeclimate.com/github/alpinelab/freeagent-exporter/coverage)

Freeagent Exporter conects to your FreeAgent account and lets you download monthly zip archives of all you attached documents.

## Supported documents

- [x] Bank transaction explainations
- [x] Bills
- [x] Expenses
- [x] Invoices

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
