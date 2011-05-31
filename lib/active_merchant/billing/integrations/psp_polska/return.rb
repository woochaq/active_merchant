require "digest/md5"

module ActiveMerchant
  module Billing
    module Integrations
      module PspPolska

        class Return < ActiveMerchant::Billing::Integrations::Return

          def valid?
            params and valid_app_id? and valid_ip? and valid_checksum?
          end

          def success?
            return false unless valid? 
            if ["sale", "recurring_start"].include?(params["action"])
              return true if status == "accepted"
            elsif params["action"] == "get_status"
              return true if status == "approved"
            elsif params["action"] == "recurring_status"
              raise StandardError, "success? method is not available for recurring_status. Pleasy use status method"
            else
              action_not_implemeted_error
            end
            false
          end

          def status
            params["status"]
          end

          def redirect_url
            params["redirect_url"]
          end

          def transaction_id
            params["transaction_id"]
          end

          def recurring_id
            params["recurring_id"]
          end

          def action
            params["action"]
          end

          def payments_count
            params["payments_count"]
          end

          def last_successful_transaction
            params["last_successful_transaction"]
          end
 
          def calculate_checksum
            if ["sale", "recurring_start"].include?(params["action"])
              Digest::MD5::hexdigest(params["app_id"] + params["session_id"] + params["status"] + params["ts"] + PspPolskaConfig['key_response'])
            elsif params["action"] == "get_status"
              Digest::MD5::hexdigest(params["app_id"] + params["transaction_id"] + params["status"] + params["ts"] + PspPolskaConfig['key_response'])
            elsif params["action"] == "recurring_status"
              Digest::MD5::hexdigest(params["app_id"] + params["recurring_id"] + params["status"] + params["ts"] + PspPolskaConfig['key_response'])
            else
              action_not_implemented_error
            end
          end

          private

          def parse(query_string)
            Hash.from_xml(query_string)["response"]
          end

          def valid_app_id?
            params["app_id"] == PspPolskaConfig['app_id']
          end

          def valid_checksum?
            params["checksum"] == calculate_checksum
          end

          def valid_ip?
            @options and @options[:ip] == PspPolskaConfig['ip']
          end

          def action_not_implemented_error
            raise StandardError, "Action not implemnted yet: #{params["action"]}"
          end
        end
      end
    end
  end
end
