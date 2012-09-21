module MP
  module SinatraHelpers
    module Auth
      include MP::Auth::Helpers

      def login_required!
        unless request.env['warden'].authenticated?
          session[:return_to] = request.path
          redirect(MP::Conf::LOGIN_URL)
        end
      end

      def merchant_required!(*roles)
        login_required!

        if current_user.roles?(:mp_admin)
          redirect(url_for(:merchant_switch)) if session[:merchant].nil?
          appcontext.env['merchant'] = Merchant.find_by_id(session[:merchant])
        else
          roles = [:merchant] if roles.empty?
          valid_role = current_user.roles.any? { |r| roles.include?(r)}
          unless current_user.merchant && valid_role
            redirect(MP::Conf::LOGIN_URL)
          end
        end
      end

      def admin_required!
        login_required!
        redirect(MP::Conf::LOGIN_URL) unless current_user.roles? :mp_admin
      end
    end
  end
end
