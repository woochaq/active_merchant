require 'net/http'
require 'digest/md5'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module PspPolska
        class Notification < ActiveMerchant::Billing::Integrations::Notification

          self.production_ips = [ PspPolskaConfig['ip'] ]

          def calculate_checksum
            Digest::MD5::hexdigest(params["app_id"] + transaction_id + params["status"] + params["ts"] + PspPolskaConfig['key_response'])
          end

          def valid?
            params and valid_sender?(@options[:ip]) and valid_app_id? and valid_checksum?
          end

          def complete?
            return false unless valid?
            return true if (["sale", "preauth", "capture"].include?(action) and status == "approved") or
              (action == "recurring_start" and status == "active") or
              (action == "recurring_stop" and status == "deactivated")
            false
          end 

          def transaction_id
            params['transaction_id'] || params['recurring_id']
          end

          def recurring_id
            params['recurring_id']
          end

          # When was this payment received by the client. 
          def received_at
            params['ts']
          end

          # the money amount we received in X.2 decimal.
          def gross
            "%.2f" % (gross_cents / 100.0)
          end

          def gross_cents
            params['amount'].to_i
          end

          def currency
            params['currency']
          end

          def action
            params['action']
          end

          def status
            params['status']
          end

          def test?
            ActiveMerchant::Billing::Base.integration_mode == :test
          end

          # Acknowledge the transaction to PspPolska. This method has to be called after a new 
          # apc arrives. PspPolska will verify that all the information we received are correct and will return a 
          # ok or a fail. 
          # 
          # Example:
          # 
          #   def ipn
          #     notify = PspPolskaNotification.new(request.raw_post)

          #     if notify.acknowledge 
          #       ... process order ... if notify.complete?
          #     else
          #       ... log possible hacking attempt ...
          #     end
          def acknowledge      
            request = PspPolskaRequest.new(acknowledge_request_options)
            res = request.send
            ret = Return.new(res.body, :ip => IPSocket::getaddress(PspPolskaConfig['domain']))
            ret.success?
          end
 private

          # Take the posted xml data and move the relevant data into a hash
          def parse(post)
            @params = Hash.from_xml(post)["response"]  
          end

          def valid_checksum?
            params["checksum"] == calculate_checksum
          end

          def valid_app_id?
            params["app_id"] == PspPolskaConfig["app_id"]
          end

          def acknowledge_request_options
            case action
            when "sale"
              {:action => "get_status", :transaction_id => transaction_id}
            when "recurring_start", "recurring_stop"
              {:action => "recurring_status", :recurring_id => transaction_id}
            else
              raise StandardError, "Invalid action: #{action}"
            end
          end

        end
      end
    end
  end
end
