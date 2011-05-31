require 'test_helper'
require 'psp_polska_test_helper'
require 'digest/md5'

class PspPolskaNotificationTest < ActiveSupport::TestCase
  include ActiveMerchant::Billing::Integrations::PspPolska

  def setup
    @sale = Notification.new(VALID_SALE, {:ip => PspPolskaConfig["ip"]})
    @recurring_start = Notification.new(VALID_RECURRING_START, {:ip => PspPolskaConfig["ip"]})
    @recurring_stop = Notification.new(VALID_RECURRING_STOP, {:ip => PspPolskaConfig["ip"]})
  end

  def test_initializer
    assert_equal @sale.params.size, 10
    assert_equal @recurring_start.params.size, 11
    assert_equal @recurring_stop.params.size, 9
  end

  def test_calculate_checksum
    assert_equal @sale.calculate_checksum, Digest::MD5.hexdigest("999999991639923858approved1303297377TestResponse1")
    assert_equal @recurring_start.calculate_checksum, Digest::MD5.hexdigest("999999991798255172active1306248938TestResponse1")
    assert_equal @recurring_stop.calculate_checksum, Digest::MD5.hexdigest("99999999112345deactivated098765TestResponse1")
  end

  def test_valid_with_correct_data_and_ip
    assert @sale.valid?
    assert @recurring_start.valid?
    assert @recurring_stop.valid?
  end

  def test_valid_with_correct_data_and_incorrect_ip
    @sale = Notification.new(VALID_SALE, {:ip => "127.0.0.1"})
    @recurring_start = Notification.new(VALID_RECURRING_START, {:ip => "127.0.0.1"})
    @recurring_stop = Notification.new(VALID_RECURRING_STOP, {:ip => "127.0.0.1"})
    ActiveMerchant::Billing::Base.integration_mode = :production
    assert !@sale.valid? 
    assert !@recurring_start.valid?
    assert !@recurring_stop.valid?
  end

  def test_valid_with_incorrect_app_id_and_correct_ip
    @sale = Notification.new(VALID_SALE.gsub("<app-id>999999991</app-id>", "<app-id>incorrect</app-id>"), {:ip => PspPolskaConfig["ip"]})
    @recurring_start = Notification.new(VALID_RECURRING_START.gsub("<app-id>999999991</app-id>", "<app-id>incorrect</app-id>"), {:ip => PspPolskaConfig["ip"]})
    @recurring_stop = Notification.new(VALID_RECURRING_STOP.gsub("<app-id>999999991</app-id>", "<app-id>incorrect</app-id>"), {:ip => PspPolskaConfig["ip"]})
    assert !@sale.valid?
    assert !@recurring_start.valid?
    assert !@recurring_stop.valid?
  end

  def test_valid_with_incorrect_checksum_and_correct_ip
    @sale = Notification.new(VALID_SALE.gsub("<checksum>64a0ac4a8f9899c89e11657122b3c39e</checksum>", "<checksum>incorrect</checksum>"), {:ip => PspPolskaConfig["ip"]})
    @recurring_start = Notification.new(VALID_RECURRING_START.gsub("<checksum>02780b71c9da20d4448ba9c1cb25c6c1</checksum>", "<checksum>incorrect</checksum>"), {:ip => PspPolskaConfig["ip"]})
    @recurring_stop = Notification.new(VALID_RECURRING_STOP.gsub("<checksum>3b72b67e8e9f059d94736b071bf10b8a</checksum>", "<checksum>incorrect</checksum>"), {:ip => PspPolskaConfig["ip"]})
    assert !@sale.valid?
    assert !@recurring_start.valid?
    assert !@recurring_stop.valid?
  end

  def test_complete
    assert @sale.complete?
    @sale.stubs(:valid?).returns(false)
    assert !@sale.complete?
    @sale.stubs(:valid?).returns(true)
    @sale.stubs(:status).returns("decline")
    assert !@sale.complete?
    assert @recurring_start.complete?
    @recurring_start.stubs(:valid?).returns(false)
    assert !@recurring_start.complete?
    @recurring_start.stubs(:valid?).returns(true)
    @recurring_start.stubs(:status).returns("unauthorized")
    @recurring_start.complete?
    assert @recurring_stop.complete?
    @recurring_stop.stubs(:valid?).returns(false)
    assert !@recurring_stop.complete?
    @recurring_stop.stubs(:valid?).returns(true)
    @recurring_stop.stubs(:status).returns("active")
    assert !@recurring_stop.complete?
  end


  def test_accessors
    assert_equal "approved", @sale.status
    assert_equal "639923858", @sale.transaction_id 
    assert_equal 100, @sale.gross_cents
    assert_equal "1.00", @sale.gross
    assert_equal "EUR", @sale.currency
    assert_equal "1303297377", @sale.received_at
    assert_equal "sale", @sale.action
    assert_equal "active", @recurring_start.status
    assert_equal "798255172", @recurring_start.transaction_id
    assert_equal 125, @recurring_start.gross_cents
    assert_equal "1.25", @recurring_start.gross
    assert_equal "PLN", @recurring_start.currency
    assert_equal "1306248938", @recurring_start.received_at
    assert_equal "recurring_start", @recurring_start.action 
    assert_equal "deactivated", @recurring_stop.status
    assert_equal "12345", @recurring_stop.transaction_id
    assert_equal 125, @recurring_stop.gross_cents
    assert_equal "1.25", @recurring_stop.gross
    assert_equal "PLN", @recurring_stop.currency
    assert_equal "098765", @recurring_stop.received_at
    assert_equal "recurring_stop", @recurring_stop.action
  end


  def test_compositions
    assert_equal Money.new(100, 'EUR'), @sale.amount
    assert_equal Money.new(125, 'PLN'), @recurring_start.amount
    assert_equal Money.new(125, 'PLN'), @recurring_stop.amount
  end
=begin
  # Replace with real successful acknowledgement code
  def test_acknowledgement    

  end

  def test_send_acknowledgement
  end

  def test_respond_to_acknowledge
    assert @psp_polska.respond_to?(:acknowledge)
  end
=end 
end
