# Rabobank transaction downloader

This gem can perform two tasks:

1. Downloading transaction statements from the Rabobank website
2. Parse each statement in these exports into a ```Transaction``` object

*NOTE* This gem logs into your bank account. I strongly recommend you to clone / vendorize this gem,
       and make sure that it performs the steps you expect before using it with your
       personal data.

## Downloading transaction statements
1. Create a instance

   ```ruby
   downloader = RabobankTransactionDownloader.new(account_nr, card_nr, icode)
   ```

   Where ```account_nr``` is your bank account number, ```card_nr``` is the 4-digit number on your card and ```icode``` is the I-number
   generated by the Random Reader.
2. Download either csv output, or parse the output directly into ```Transaction``` objects.

   ```ruby
   downloader.download_csv(accounts, since, up_to_and_including)          # returns a multi-line CSV string
   downloader.download_transactions(accounts, since, up_to_and_including) # returns an array of Transaction objects.
   ```

   Where ```accounts``` is either ```:all```, to download transactions from all your accounts, or an array of accountnumbers that you'd like to download.
   These accountnumbers can be be retrieved with ```downloader.available_accounts```.

See [the demo](doc/demo.rb) for a working example.

## Parsing the CSV output
Based Rabobank [documentation](https://bankieren.rabobank.nl/klanten/static/images/formaatbeschrijving_csv_kommagescheiden_nieuw_30539176.pdf).

#### Basic methods
Each transaction object has the following methods, which map directly to the columns specified in the documentation:
 - owner_account_nr
 - currency
 - interest_date
 - type
 - amount
 - contra_account_number
 - contra_account_name
 - entry_date
 - transaction_type
 - filler
 - description1
 - description2
 - description3
 - description4
 - description5
 - description6
 - sepa_end_to_end_id
 - sepa_contra_account_id
 - sepa_mandate_id

#### Additional helpers
 There are several additional helper methods:
 - ```debit?``` which returns ```true``` if this is a debit transaction
 - ```credit?``` which returns ```true``` if this is a credit transaction
 - ```description``` which returns the concatonation of the 6 description fields.
 - ```transaction_type_name``` which returns a human readable name (in dutch) of the transaction type
   (see [wikipedia](http://nl.wikipedia.org/wiki/Rekeningafschrift) for a list of these types)
