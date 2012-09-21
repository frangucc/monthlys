module MP
  module Routes
    class Wizard < RoutesBase
      get url(:wizard, '/wizard/') do
        merchant_required!

        render 'wizard/assistance'
      end

      post url(:wizard) do
        merchant_required!

        redirect url_for(:plan_new) if params[:assistance] == 'no'

        QC.enqueue('MP::Jobs::Merchants.send_assistance_email', {
          'user' => current_user.id
        })
        QC.enqueue('MP::Jobs::Admin.send_user_assistance_email', {
          'user' => current_user.id
        })
        render 'wizard/assistance_document'
      end
    end

  end

  Main.use Routes::Wizard
end
