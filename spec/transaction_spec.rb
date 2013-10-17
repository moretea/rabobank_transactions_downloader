require "rabobank_transactions_downloader/transaction"

FIXTURE_CSV = File.read(File.expand_path("../fixture.csv", __FILE__))
ROWS = CSV.parse(FIXTURE_CSV)
FIXTURE_DEBIT  = ROWS[0] # first line
FIXTURE_CREDIT = ROWS[23] # line 24
FIXTURE_DESCRIPTION = ROWS[33] # line 34
ROW1 = ROWS[1]
ROW2 = ROWS[2]

class RabobankTransactionDownloader
  describe Transaction do
    describe "identity" do
      context "the same row, parsed twice" do
        let(:rowx) { Transaction.new(FIXTURE_DEBIT) }
        let(:rowy) { Transaction.new(FIXTURE_DEBIT) }
        it "is considered to be equal" do
          rowx.should == rowy
        end
      end

      context "two different rows" do
        let(:rowx) { Transaction.new(FIXTURE_DEBIT) }
        let(:rowy) { Transaction.new(FIXTURE_CREDIT) }
        it "is considered to be different" do
          rowx.should_not == rowy
        end
      end

      describe "all transactions" do
        it "should be equal" do
          Transaction.all_from_csv(FIXTURE_CSV).should == Transaction.all_from_csv(FIXTURE_CSV)
        end
      end
    end

    describe "parsing a whole csv file" do
      def parse_transactions
        described_class.all_from_csv(FIXTURE_CSV)
      end

      it "does not fail" do
        expect { parse_transactions }.not_to raise_error
      end

      it "has the correct number of transactions" do
        parse_transactions.length.should == 34
      end

      it "is equivalent to parsing each line separately" do
        parse_transactions.should == ROWS.collect { |row| Transaction.new(row) }
      end
    end

    describe "debit transaction" do
      let(:transaction) { Transaction.new(FIXTURE_DEBIT) }

      it "should be a debit transaction" do
        transaction.debit?.should == true
      end

      it "should not be a credit transaction" do
        transaction.credit?.should == false
      end
    end

    describe "credit transaction" do
      let(:transaction) { Transaction.new(FIXTURE_CREDIT) }

      it "should not be a debit transaction" do
        transaction.debit?.should == false
      end

      it "should be a credit transaction" do
        transaction.credit?.should == true
      end
    end

    describe "amount" do
      describe "of row 1" do
        it "is correct" do
          Transaction.new(ROW1).amount.should == 200
        end
      end
      describe "of row 2" do
        it "is correct" do
          Transaction.new(ROW2).amount.should == 4000
        end
      end
      describe "with 1 cent" do
        it "is correct" do
          Transaction.new(FIXTURE_DESCRIPTION).amount.should == 0.01
        end
      end
    end

    describe "description" do
      it "concatenates the different parts" do
        Transaction.new(FIXTURE_DESCRIPTION).description.should == "Veel te lange omschrijving die er totaal niet toe doet, maar omdat ikiets moet invullen doe ik dat dus nu zo maar, klopt het aantal tekens?"
      end
    end
  end
end
