#!/usr/bin/env bash
# Imports financial transactions from Money Money
# The database is encrypted using sqlcipher cipher version 3.
# The encryption key is stored in Apple Keychain.

USER=$(whoami)
MONEY_MONEY_KEYCHAIN_KEY=${MONEY_MONEY_KEYCHAIN_KEY:=moneymoney}
PRAGMA_KEY=$(security find-generic-password -a "$USER" -s $MONEY_MONEY_KEYCHAIN_KEY -w)

sqlcipher -readonly ~/Library/Containers/com.moneymoney-app.retail/Data/Library/Application\ Support/MoneyMoney/Database/MoneyMoney.sqlite "
PRAGMA key = '${PRAGMA_KEY}';
PRAGMA cipher_compatibility = 3;
SELECT
    json_object(
        'provider', 'MoneyMoney',
        'verb', 'transacted',
        'id', 'moneymoney-' || transactions.rowid,
        'date_month', strftime('%Y-%m', transactions.timestamp, 'unixepoch', 'utc'),
        'timestamp_utc', datetime(transactions.timestamp, 'unixepoch', 'utc'),
        'timestamp_unix', transactions.timestamp,
        'transaction_account_name', accounts.name,
        'transaction_category', categories.name,
        'transaction_amount', transactions.amount,
        'transaction_currency', transactions.currency,
        'transaction_recipient', transactions.name,
        'transaction_purpose', transactions.unformatted_purpose
  ) AS json
FROM transactions
LEFT JOIN accounts ON transactions.local_account_key=accounts.rowid
LEFT JOIN categories ON transactions.category_key=categories.rowid
" \
  | awk '!/^ok$/' \
  | jq -s '.' \
  | jq  \
  'map(
    . +
    (
      if .transaction_purpose | test("(?<day>\\d{2})-(?<month>\\d{2})-(?<year>\\d{4}) (?<hours>\\d{2}):(?<minutes>\\d{2})") then
        .transaction_purpose
          | capture("(?<day>\\d{2})-(?<month>\\d{2})-(?<year>\\d{4}) (?<hours>\\d{2}):(?<minutes>\\d{2})")
          | {
            timestamp_unix: (.year + "-" + .month + "-" + .day + "T" + .hours + ":" + .minutes + ":00" + "Z") | fromdate,
            timestamp_utc: (.year + "-" + .month + "-" + .day + " " + .hours + ":" + .minutes)
          }
      else
        {}
      end
    )
  )' \
  | jq -r '.[]'
# awk => needed to filter out "ok" response from PRAGMA
# jq  => Fix timestamp with actual date if possible