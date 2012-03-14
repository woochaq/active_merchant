require 'digest/md5'
require 'test_helper'

class TransferujHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def setup
    @helper = Transferuj::Helper.new('order-500','cody@example.com', :amount => 500, :currency => 'USD', :credential2 => '1010')
  end
 
  def test_basic_helper_fields
    assert_field 'kwota', '5.00'
    assert_field 'opis', 'order-500'
    assert_field 'crc', 'order-500'
    assert_field 'md5sum', Digest::MD5::hexdigest('cody@example.com5.00order-5001010')
  end
  
  def test_customer_fields
    @helper.customer :first_name => 'Cody', :last_name => 'Fauser', :email => 'cody@example.com'
    assert_field 'imie', 'Cody'
    assert_field 'nazwisko', 'Fauser'
    assert_field 'email', 'cody@example.com'
  end

  def test_address_mapping
    @helper.billing_address :address1 => '1 My Street',
                            :address2 => '',
                            :city => 'Leeds',
                            :state => 'Yorkshire',
                            :zip => 'LS2 7EE',
                            :country  => 'CA'
   
    assert_field 'adres', '1 My Street'
    assert_field 'miasto', 'Leeds'
    assert_field 'kod', 'LS2 7EE'
  end
  
  def test_unknown_address_mapping
    @helper.billing_address :farm => 'CA'
    assert_equal 5, @helper.fields.size
  end

  def test_unknown_mapping
    assert_nothing_raised do
      @helper.company_address :address => '500 Dwemthy Fox Road'
    end
  end
  
  def test_setting_invalid_address_field
    fields = @helper.fields.dup
    @helper.billing_address :street => 'My Street'
    assert_equal fields, @helper.fields
  end
end
