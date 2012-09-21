require 'warden'
require 'bcrypt'

module MP
  module Auth
    class BadEmail < ArgumentError; end
    class BadPassword < ArgumentError; end
    class NonMerchantLogin < ArgumentError; end

    # Based on devise implementation
    # Constant-time comparison algorithm to prevent timing attacks
    def self.secure_compare(a, b)
      return false if a.blank? || b.blank? || a.bytesize != b.bytesize
      l = a.unpack "C#{a.bytesize}"

      res = 0
      b.each_byte { |byte| res |= byte ^ l.shift }
      res == 0
    end

    def self.authenticate_for(user, clear_password)
      p user.id
      salt = ::BCrypt::Password.new(user.encrypted_password).salt
      ppw = "#{clear_password}#{Monthly::Config::WARDEN_PASSWORD_PEPPER}"
      streches = Monthly::Config::WARDEN_PASSWORD_STRETCHES
      password = ::BCrypt::Engine.hash_secret(ppw, salt, streches)
      secure_compare(password, user.encrypted_password)
    end


    module Helpers
      def authenticate!
        appcontext.env['warden'].authenticate(:password)
      end

      def logout!
        appcontext.env['warden'].logout
      end

      def current_user
        appcontext.env['warden'].user
      end

      def current_merchant
        if current_user.roles?(:mp_admin) && !appcontext.env['merchant'].nil?
          appcontext.env['merchant']
        elsif !current_user.merchant.nil?
          current_user.merchant
        end
      end

      # Assumes valid merchant
      def switch_merchant(merchant)
        if appcontext.current_user.roles?(:mp_admin)
          session[:merchant] = merchant.id
        end
      end

      def authenticated?
        appcontext.env['warden'].authenticated?
      end
    end

    class PasswordStrategy < ::Warden::Strategies::Base

      def valid?
        params['email'] && params['password']
      end

      def authenticate!
        user = User.find_by_email(params['email'])
        raise MP::Auth::BadEmail unless user

        valid = MP::Auth.authenticate_for(user, params['password'])
        raise MP::Auth::BadPassword unless valid

        unless user.roles?(:mp_admin)
          raise MP::Auth::NonMerchantLogin if !user.roles?(:merchant) || !user.merchant
        end

        success!(user)
      end
    end

  end
end

::Warden::Strategies.add(:password, MP::Auth::PasswordStrategy)
