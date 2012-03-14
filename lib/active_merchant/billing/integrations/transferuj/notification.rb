require 'net/http'
require 'digest/md5'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Transferuj
        class Notification < ActiveMerchant::Billing::Integrations::Notification

          attr_accessor :secret

          def initialize(data, options = {})
            if options[:secret].nil?
              options[:secret] = ''
            end
            self.secret = options.delete(:secret).to_s
            super
          end

          def complete?
            params['tr_status']
          end 

          def item_id
            params['tr_crc']
          end

          def transaction_id
            params['tr_id']
          end

          # When was this payment received by the client. 
          def received_at
            params['tr_date']
          end

          def payer_email
            params['tr_email']
          end
          
          def security_key
            params['md5sum']
          end

          # the money amount we received in X.2 decimal.
          def gross
            params['tr_amount']
          end
 
          def status
            params['tr_error']
          end

          def merchant_id
            params['id']
          end

          def checksum
            params['md5sum']
          end
 
          # Acknowledge the transaction to Transferuj. This method has to be called after a new 
          # apc arrives. Transferuj will verify that all the information we received are correct and will return a 
          # ok or a fail. 
          # 
          # Example:
          # 
          #   def ipn
          #     notify = TransferujNotification.new(request.raw_post)
          #
          #     if notify.acknowledge 
          #       ... process order ... if notify.complete?
          #     else
          #       ... log possible hacking attempt ...
          #     end
          def acknowledge      
            fields = [merchant_id, transaction_id, gross, item_id, secret].join
            checksum == Digest::MD5.hexdigest(fields)
          end
 private

          # Take the posted data and move the relevant data into a hash
          def parse(post)
            @raw = post
            for line in post.split('&')
              key, value = *line.scan( %r{^(\w+)\=(.*)$} ).flatten
              params[key] = value
            end
          end
        end
      end
    end
  end
end
