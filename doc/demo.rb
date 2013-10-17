#!/usr/bin/env ruby
require "rabobank_transactions_downloader"

def ask(question)
  puts question
  print "> "
  gets.chomp
end

account_nr = ask("Your account number:")
card_nr    = ask("Your card number:")
icode      = ask("Your I code for this session:")

downloader = RabobankTransactionDownloader.new(account_nr, card_nr, icode)

puts
puts "Available accounts:"
p downloader.available_accounts

all_transactions = downloader.download_transactions(:all)

all_transactions.each do |transaction|
  p transaction
end
