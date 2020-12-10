KEY=$(security find-generic-password -a adrimbp -s moneymoney -w)
sqlcipher -readonly ~/Library/Containers/com.moneymoney-app.retail/Data/Library/Application\ Support/MoneyMoney/Database/MoneyMoney.sqlite "
PRAGMA key = "${KEY}";
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
" | awk '!/^ok$/'
# needed ot filter out "ok" response from PRAGMA


