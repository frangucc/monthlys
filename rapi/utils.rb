require 'digest/sha2'
require 'bigdecimal'

module Monthly
  module Rapi

    module Utils
      module_function

      # Convert cents to dollars, int => BigDecimal
      def convert_to_usd(amount_in_cents)
        (amount_in_cents) ? BigDecimal.new(amount_in_cents.to_s) / 100 : 0
      end

      # Converts dollars to cents, BigDecimal => int (ceil)
      def convert_to_cents(amount_in_usd)
        (amount_in_usd) ? (amount_in_usd * 100).ceil : 0
      end

      # Generate unique code, used for recurly account/plan codes.
      def ucode(str, length = 6)
        hash = Digest::SHA1.hexdigest(str.to_s + Time.now.to_s)[0, length]
        "#{str.to_s}-#{hash}"
      end
    end

  end
end
