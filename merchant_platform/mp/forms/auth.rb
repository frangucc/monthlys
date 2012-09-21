require mp_path('mp/forms/base')

module MP
  module Forms

    class Login < Form
      email  :email, label: 'Email'
      password :password, label: 'Password'

      def clean
        begin
          appcontext.authenticate!
        rescue MP::Auth::BadEmail, MP::Auth::BadPassword
          fail_validation('Invalid email/password combination.')
        rescue MP::Auth::NonMerchantLogin
          fail_validation('This account is not a merchant account.')
        end
        cleaned_data
      end
    end

  end
end
