require 'test_helper'
require 'psp_polska_test_helper'

class PspPolskaReturnTest < ActiveSupport::TestCase
  include ActiveMerchant::Billing::Integrations::PspPolska

  def test_empty_response_should_not_create_valid_return
    r = Return.new("<request></request>")
    assert !r.valid?
  end

  def test_valid_response_should_create_valid_return
    sale = Return.new(VALID_SALE_RESPONSE, :ip => PspPolskaConfig["ip"])
    assert sale.valid?
    get_status = Return.new(VALID_GET_STATUS_RESPONSE, :ip => PspPolskaConfig["ip"])
    assert get_status.valid?
    recurring_start = Return.new(VALID_RECURRING_START_RESPONSE, :ip => PspPolskaConfig["ip"])
    assert recurring_start.valid?
    recurring_status = Return.new(VALID_RECURRING_STATUS_RESPONSE, :ip => PspPolskaConfig["ip"])
    assert recurring_status.valid?
  end

  def test_valid_response_should_create_invalid_return_without_ip
    sale = Return.new(VALID_SALE_RESPONSE)
    assert !sale.valid?
    get_status = Return.new(VALID_GET_STATUS_RESPONSE)
    assert !get_status.valid?
    recurring_start = Return.new(VALID_RECURRING_START_RESPONSE)
    assert !recurring_start.valid?
    recurring_status = Return.new(VALID_RECURRING_STATUS_RESPONSE)
    assert !recurring_status.valid?
  end
  
  def test_valid_response_should_create_invalid_return_with_incorrect_ip
    sale = Return.new(VALID_SALE_RESPONSE, :ip => "127.0.0.1")
    assert !sale.valid?
    get_status = Return.new(VALID_GET_STATUS_RESPONSE, :ip => "127.0.0.1")
    assert !get_status.valid?
    recurring_start = Return.new(VALID_RECURRING_START_RESPONSE, :ip => "127.0.0.1")
    assert !recurring_start.valid?
    recurring_status = Return.new(VALID_RECURRING_STATUS_RESPONSE, :ip => "127.0.0.1")
    assert !recurring_status.valid?
  end

  def test_calculate_checksum
    sale = Return.new(VALID_SALE_RESPONSE)
    assert_equal sale.calculate_checksum, Digest::MD5.hexdigest("999999991some_session_idaccepted1303297377TestResponse1")
    get_status = Return.new(VALID_GET_STATUS_RESPONSE)
    assert_equal get_status.calculate_checksum, Digest::MD5.hexdigest("999999991725411585approved1304589448TestResponse1")
    recurring_start = Return.new(VALID_RECURRING_START_RESPONSE)
    assert_equal recurring_start.calculate_checksum, Digest::MD5.hexdigest("999999991some_session_idaccepted1305781394TestResponse1")
    recurring_status = Return.new(VALID_RECURRING_STATUS_RESPONSE)
    assert_equal recurring_status.calculate_checksum, Digest::MD5.hexdigest("9999999911234active5678TestResponse1")
  end

  def test_success?
    sale = Return.new(VALID_SALE_RESPONSE, :ip => PspPolskaConfig["ip"])
    assert sale.success?
    sale = Return.new(
      VALID_SALE_RESPONSE.gsub("<status>accepted</status>", "<status>declined</status>"),
      :ip => PspPolskaConfig["ip"])
    sale.stubs(:valid?).returns(true)
    assert sale.valid?
    assert !sale.success?
    get_status = Return.new(VALID_GET_STATUS_RESPONSE, :ip => PspPolskaConfig["ip"])
    assert get_status.success?
    get_status = Return.new(
      VALID_GET_STATUS_RESPONSE.gsub("<status>approved</status>", "<status>accepted</status>"),
      :ip => PspPolskaConfig["ip"])
    get_status.stubs(:valid?).returns(true)
    assert get_status.valid?
    assert !get_status.success?
    recurring_start = Return.new(VALID_RECURRING_START_RESPONSE, :ip => PspPolskaConfig["ip"])
    assert recurring_start.success?
    recurring_start = Return.new(
      VALID_RECURRING_START_RESPONSE.gsub("<status>accepted</status>", "<status>declined</status>"),
      :ip => PspPolskaConfig["ip"]
    )
    recurring_start.stubs(:valid?).returns(true)
    assert recurring_start.valid?
    assert !recurring_start.success?
    recurring_status = Return.new(VALID_RECURRING_STATUS_RESPONSE, :ip => PspPolskaConfig["ip"])
    assert_raise(StandardError) { recurring_status.success? }
  end

  def test_redirect_url
    sale = Return.new(VALID_SALE_RESPONSE)
    assert_equal sale.redirect_url, "https://sandbox.psp-polska.pl/transaction/credit_card/sale/639923858"
    get_status = Return.new(VALID_GET_STATUS_RESPONSE)
    assert_equal get_status.redirect_url, nil
    recurring_start = Return.new(VALID_RECURRING_START_RESPONSE)
    assert_equal recurring_start.redirect_url, "https://sandbox.psp-polska.pl/transaction/credit_card/recurring/764714872"
    recurring_status = Return.new(VALID_RECURRING_STATUS_RESPONSE)
    assert_equal recurring_status.redirect_url, nil
  end

  def test_recurring_info
    recurring_status = Return.new(VALID_RECURRING_STATUS_RESPONSE)
    assert_equal recurring_status.payments_count, 1
    assert_equal recurring_status.last_successful_transaction, {"transaction_id"=>"778924173", "date"=>"2011-05-19", "status"=>"approved"}
  end
end
