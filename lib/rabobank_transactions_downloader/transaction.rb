require "csv"
require "bigdecimal"

class RabobankTransactionDownloader::Transaction
  def self.all_from_csv(csv)
    begin
      rows = CSV.parse(csv)
    rescue CSV::MalformedCSVError => e
      puts e.message
      puts "CSV:"
      puts csv
    end
    rows.collect do |row|
      self.new(row)
    end
  end

  ATTRS = [
    :owner_account_nr,
    :currency,
    :interest_date,
    :type,
    :amount,
    :contra_account_number,
    :contra_account_name,
    :entry_date,
    :transaction_type,
    :filler,
    :description1,
    :description2,
    :description3,
    :description4,
    :description5,
    :description6,
    :sepa_end_to_end_id,
    :sepa_contra_account_id,
    :sepa_mandate_id
  ]

  # List taken from http://nl.wikipedia.org/wiki/Rekeningafschrift
  TRANSACTION_TYPE_MAPPING = {
    "c"  => "acceptgiro",
    "ba" => "betaalautomaat",
    "bg" => "bankgiro opdracht",
    "cb" => "crediteurenbetaling",
    "ck" => "Chipknip",
    "db" => "diverse boekingen",
    "ga" => "geldautomaat Euro",
    "gb" => "geldautomaat VV",
    "id" => "iDEAL",
    "kh" => "kashandeling",
    "ma" => "machtiging",
    "nb" => "NotaBox",
    "sb" => "salaris betaling",
    "tb" => "eigen rekening",
    "tg" => "telegiro",
    "CR" => "tegoed",
    "D"  => "tekort"
  }

  attr_reader *ATTRS

  def initialize(csv_row)
    @owner_account_nr       = csv_row[0]
    @currency               = csv_row[1]
    @interest_date          = parse_rabo_date csv_row[2]
    @type                   = csv_row[3]
    @amount                 = BigDecimal.new csv_row[4]
    @contra_account_number  = csv_row[5]
    @contra_account_name    = csv_row[6]
    @entry_date             = parse_rabo_date csv_row[7]
    @transaction_type       = csv_row[8]
    @filler                 = csv_row[9]
    @description1           = csv_row[10]
    @description2           = csv_row[11]
    @description3           = csv_row[12]
    @description4           = csv_row[13]
    @description5           = csv_row[14]
    @description6           = csv_row[15]
    @sepa_end_to_end_id     = csv_row[16]
    @sepa_contra_account_id = csv_row[17]
    @sepa_mandate_id        = csv_row[18]
  end

  def ==(other)
    ATTRS.all? do |attr|
      self.send(attr) == other.send(attr)
    end
  end

  def debit?
    @type == "D"
  end

  def credit?
    @type == "C"
  end

  def description
    [@description1, @description2, @description3, @description4, @description5, @description6].collect(&:to_s).join("")
  end

  def transaction_type_name
    TRANSACTION_TYPE_MAPPING[@transaction_type]
  end

  protected

  RABO_DATE_FORMAT = "%Y%m%d"

  def parse_rabo_date(date)
    Date.strptime(date, RABO_DATE_FORMAT)
  end
end
