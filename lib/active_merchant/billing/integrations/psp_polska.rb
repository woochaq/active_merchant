require File.dirname(__FILE__) + '/psp_polska/notification.rb'
require File.dirname(__FILE__) + '/psp_polska/psp_polska_request.rb'
require File.dirname(__FILE__) + '/psp_polska/return.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module PspPolska 
        
        def self.notification(post)
          Notification.new(post)
        end  
      end
    end
  end
end
