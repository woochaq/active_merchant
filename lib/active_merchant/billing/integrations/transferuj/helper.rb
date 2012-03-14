require 'digest/md5'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Transferuj
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          # Replace with the real mapping
          mapping :account, 'id'
          mapping :amount, 'kwota'
        
          mapping :order, 'opis'
          mapping :md5sum, 'md5sum'
          mapping :crc, 'crc'

          mapping :customer, :first_name => 'imie',
                             :last_name  => 'nazwisko',
                             :email      => 'email',
                             :phone      => 'telefon'

          mapping :billing_address, :city     => 'miasto',
                                    :address1 => 'adres',
                                    :zip      => 'kod',
                                    :country  => 'kraj'

          mapping :credential3, 'wyn_url'
          mapping :return_url, 'pow_url'
          mapping :cancel_return_url, 'pow_url_blad'

          def initialize(order, account, options = {})
            if options[:credential2].nil?
              options[:credential2] = ''
            end
            super
            add_field(mappings[:crc], order)
            string = account.to_s + @amount.to_s + order.to_s + options.delete(:credential2).to_s
            add_field(mappings[:md5sum], Digest::MD5::hexdigest(string))
          end

          def amount=(money)
            cents = money.respond_to?(:cents) ? money.cents : money
            if money.is_a?(String) or cents.to_i <= 0
              raise ArgumentError, 'money amount must be either a Money object or a positive integer in cents'
            end
            @amount =  sprintf("%.2f", cents.to_f/100)
            add_field(mappings[:amount], @amount)
          end

        end
      end
    end
  end
end
