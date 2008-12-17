require 'openssl'
require 'net/https'
require 'base64'
require 'digest/sha1'

require File.dirname(__FILE__) + '/ideal/ideal_base'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    # First, make sure you have everything setup correctly and all of your dependencies in place with:
    # 
    #   require 'rubygems'
    #   require 'active_merchant'
    #
    # ActiveMerchant expects the amounts to be given as an Integer in cents. In this case, 10 EUR becomes 1000.
    #
    # Configure the gateway using your Ideal account info and security settings:
    #
    # Create gateway:
    # gateway = ActiveMerchant::Billing::IdealIngPostbankGateway.new(
    #   :login    => "123456789",
    #   :pem      => File.read(RAILS_ROOT + '/config/ideal.pem'),
    #   :password => "password"
    # )
    #
    # Get list of issuers to fill selection list on your payment form:
    # response = gateway.issuers
    # list = response.issuer_list
    #
    # Request transaction:
    #
    # options = {
    #    :issuer_id=>'0001', 
    #    :expiration_period=>'PT10M', 
    #    :return_url =>'http://www.return.url', 
    #    :order_id=>'1234567890123456', 
    #    :currency=>'EUR', 
    #    :description => 'Een omschrijving', 
    #    :entrance_code => '1234'
    # }    
    #
    # response = gateway.setup_purchase(amount, options)
    # transaction_id = response.transaction['transactionID']
    # redirect_url = response.service_url
    #   
    # Mandatory status request will confirm transaction:
    # response = gateway.capture(:transaction_id => transaction_id)
    #
    # Implementation contains some simplifications
    # - does not support multiple subID per merchant
    # - language is fixed to 'nl'
    class IdealIngPostbankGateway < IdealBaseGateway
      class_inheritable_accessor :test_url, :live_url
  
      self.test_url = "https://idealtest.secure-ing.com/ideal/iDeal"
      self.live_url = "https://ideal.secure-ing.com/ideal/iDeal"    
      self.server_pem = File.read(File.dirname(__FILE__) + '/ideal/ideal_ing_postbank.pem')
    end
  end
end
