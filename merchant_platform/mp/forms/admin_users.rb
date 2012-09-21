require mp_path('mp/forms/base')

module MP
  module Forms

    class EditAdminUser < Form
      USER_ROLES = [ [:merchant, 'Administrator'],
                     [:merchant_support, 'Support'] ]

      choice :roles, USER_ROLES
      string :full_name
      email :email

      def clean_roles
        role = cleaned_data[:roles].to_sym
        valid_roles = USER_ROLES.map{|k, v| k}
        fail_validation('Invalid role.') unless valid_roles.include?(role)
        [role]
      end

      def clean_email
        email = cleaned_data[:email]
        fail_validation('Email in use.') if User.find_by_email(email)
        email
      end

      def save(record)
        record.merchant = appcontext.current_merchant

        super(record)
      end
    end


    class NewAdminUser < EditAdminUser
      password :password
      password :password2

      def clean_password2
        p1, p2 = cleaned_data[:password], cleaned_data[:password2]
        fail_validation('Passwords don\'t match.') if p1 != p2
        p2
      end

      def save(record)
        plain_password = cleaned_data.delete(:password)
        record.set_password(plain_password)
        super(record)
      end
    end


    class UserChangePassword < Form
      password :old_password, label: 'Current password'
      password :new_password, label: 'New password'
      password :new_password2, label: 'Repeat new password'

      def clean_old_password
        old_password = cleaned_data[:old_password]
        if !MP::Auth.authenticate_for(record, old_password)
          fail_validation('Bad password.')
        end
        old_password
      end

      def clean_new_password2
        p1, p2 = cleaned_data[:new_password], cleaned_data[:new_password2]
        fail_validation('Passwords don\'t match.') if p1 != p2
        p2
      end

      def save(record)
        plain_password = cleaned_data.fetch(:new_password)
        record.set_password(plain_password)
        record.save(validate: false)
      end
    end

  end
end
