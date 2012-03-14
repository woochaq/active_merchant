require 'test_helper'

class TransferujModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def test_notification_method
    assert_instance_of Transferuj::Notification, Transferuj.notification('name=cody', :secret => 'secret')
  end
end 
