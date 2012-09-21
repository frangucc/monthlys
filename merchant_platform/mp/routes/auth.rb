require mp_path('mp/forms/auth.rb')

module MP
  module Routes
    class Auth < RoutesBase
      get url(:login, '/login/') do
        render 'auth/login', {
          form: MP::Forms::Login.new
        }
      end

      post url(:login) do
        form = MP::Forms::Login.new(params)

        if form.valid?
          redirect(MP::Conf::LOGIN_REDIRECT_DEFAULT_URL)
        end

        render 'auth/login', {
          form: form
        }
      end


      get url(:logout, '/logout/') do
        logout!
        redirect(MP::Conf::LOGOUT_REDIRECT_URL)
      end


      get url(:merchant_switch, '/switch/') do
        admin_required!
        render('auth/merchant_switch')
      end

      post url(:merchant_switch) do
        admin_required!
        redirect(url_for(:merchant_switch)) if params[:merchant].blank?

        merchant = Merchant.find_by_id(params[:merchant])

        if merchant.nil?
          redirect(url_for(:merchant_switch))
        else
          switch_merchant(merchant)
          redirect(url_for(:dashboard))
        end
      end

    end
  end

  Main.use Routes::Auth
end
