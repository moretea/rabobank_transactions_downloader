require "capybara"
require "capybara/webkit"

class RabobankTransactionDownloader
  include Capybara::DSL

  LOGIN_URL="https://bankieren.rabobank.nl/klanten"
  DOWNLOAD_URL="https://bankieren.rabobank.nl/klanten/particulieren/internetbankieren/betalensparen/downloaden_transacties/"

  class Error < Exception; end
  class CouldNotLogIn < Error; end

  def initialize(account_nr, card_nr, icode)
    @account_nr = account_nr
    login(account_nr, card_nr, icode)
  end

  # List available accounts
  def available_accounts
    @available_accounts ||= begin
      with_capybara_config do
        visit DOWNLOAD_URL
        all(".ra_bh_togglecheckbox").collect { |node| node[:id] }
      end
    end
  end


  def attempt(times=5, delay=0.5)
    attempts_left = times
    while true
      attempts_left -=1
      begin
        yield
        return
      rescue Exception => e
        if attempts_left > 0
          next
        else
          raise e
        end
      end
    end
  end

  def download_csv(what, since = nil, up_to_and_including = nil)
    with_capybara_config do
      visit DOWNLOAD_URL

      if what == :all
        attempt { find(:css, "#selectAllPossibleAccounts").set(true) }
      else
        if what.kind_of?(Array)
          to_check = what
        else
          to_check = [what]
        end

        to_check.each do |account_nr|
          attempt { check account_nr.to_s }
        end
      end

      fill "fromdate", with: since               if since != nil
      fill "todate",   with: up_to_and_including if up_to_and_including != nil

      perform_and_wait_until_page_changed do
        find(:css, "input[name='downloadByBookDate']").click
      end

      wait_done_loading

      page.body
    end
  end

  def download_transactions(what, since = nil, up_to_and_including = nil)
    csv = download_csv(what, since, up_to_and_including)
    Transaction.all_from_csv(csv)
  end

  protected

  def perform_and_wait_until_page_changed(attempts = 20 * 10, wait = 0.1)
    current = page.current_url

    yield

    attempts_left = attempts

    while true
      attempts_left -= 1
      if page.current_url != current
        break
      else
        if attempts_left > 0
          sleep wait
          next
        else
          raise "Changing page took too long"
        end
      end
    end
  end

  def wait_done_loading(attempts = 20 * 10, wait = 0.1)
    attempts_left = attempts
    while true
      if page.driver.evaluate_script("document.readyState") == "complete"
        break
      else
        attempts_left -= 1
        if attempts_left > 0
          sleep wait
          next
        else
          p page.driver.evaluate_script("document.readyState")
          raise "Loading took too long"
        end
      end
    end
  end

  def login(account_nr, card_nr, icode)
    with_capybara_config do
      visit LOGIN_URL
      fill_in "AuthId",     with: account_nr
      fill_in "AuthBpasNr", with: card_nr
      fill_in "AuthCd",     with: icode
      click_button "brt_but_submit"

      if all("#ra_uitloggen").length < 1
        raise CouldNotLogIn.new
      end
    end
  end

  def with_capybara_config
    old = [Capybara.current_driver, Capybara.app_host, Capybara.run_server]
    Capybara.current_driver = :webkit
    Capybara.app_host = nil
    Capybara.run_server = false

    begin
      yield
    ensure
      Capybara.current_driver, Capybara.app_host, Capybara.run_server = old
    end
  end
end

require "rabobank_transactions_downloader/transaction"
