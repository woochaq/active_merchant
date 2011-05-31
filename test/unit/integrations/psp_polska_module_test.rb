require 'test_helper'

class PspPolskaModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def test_notification_method
    assert_instance_of PspPolska::Notification, PspPolska.notification('<response><key>value</key></response>')
  end
end 
