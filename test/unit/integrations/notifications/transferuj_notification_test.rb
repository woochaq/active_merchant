require 'test_helper'

class TransferujNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @transferuj = Transferuj::Notification.new(http_raw_data, :secret => 1010)
  end

  def test_initializer
    @transferuj = Transferuj::Notification.new(http_raw_data)
    assert_equal @transferuj.secret, ''
  end

  def test_accessors
    assert @transferuj.complete?
    assert_equal "none", @transferuj.status
    assert_equal "666", @transferuj.transaction_id
    assert_equal "order-500", @transferuj.item_id
    assert_equal "5.00", @transferuj.gross
    assert_equal "11.11.2011", @transferuj.received_at
    assert_equal '1010', @transferuj.merchant_id
    assert_equal '1010', @transferuj.secret
    assert_equal '9428dbdd5b2c03341a4f4c3b71c0e5a2', @transferuj.checksum
  end

  def test_compositions
    assert_equal Money.new(500, 'USD'), @transferuj.amount
  end

  # Replace with real successful acknowledgement code
  def test_acknowledgement    
    assert @transferuj.acknowledge
  end

  def test_respond_to_acknowledge
    assert @transferuj.respond_to?(:acknowledge)
  end

  private
  def http_raw_data
    "id=1010&tr_id=666&tr_date=11.11.2011&tr_crc=order-500&tr_amount=5.00&tr_paid=5.00&tr_desc=description&tr_status=TRUE&tr_error=none&tr_email=customer@example.com&md5sum=9428dbdd5b2c03341a4f4c3b71c0e5a2"
  end  
end
