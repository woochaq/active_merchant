require File.dirname(__FILE__) + '/transferuj/helper.rb'
require File.dirname(__FILE__) + '/transferuj/notification.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Transferuj 
       
        mattr_accessor :service_url
        self.service_url = 'https://secure.transferuj.pl'

        def self.notification(post, options = {})
          Notification.new(post, options)
        end  
      end
    end
  end
end
