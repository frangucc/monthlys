ActiveAdmin.register Transaction, as: 'Refund' do

  menu parent: 'Subscriptions'
  actions :index, :show, :new, :create

  around_filter &(Monthly::AdminActivityLogger.get_around_filter_block_for('Transaction', { instance_var_name: 'refund' }) do |transaction, attributes|
    attributes.delete(:invoice_id)
    attributes.merge({
      invoice: transaction.invoice ? { id: transaction.invoice_id, desc: transaction.invoice.to_s } : nil
    })
  end)

  index do
    column :id
    column :created_at
    column :user do |t|
      if t.invoice && t.invoice.user
        link_to t.invoice.user.email, admin_user_path(t.invoice.user)
      end
    end
    column :amount
    column :invoice do |t|
      t.invoice.invoice_number
    end

    default_actions
  end

  form do |f|
    f.inputs do
      f.input :invoice, as: :select, collection: Invoice.where('user_id IS NOT NULL').order('invoice_number DESC').all, include_blank: false
      f.input :amount, label: 'Amount to refund'
    end
    f.buttons
  end

  sidebar :about_refunds, only: :index do
    ul do
      li "An unsettled transaction can be voided stopping the transaction from processing and removing it from the account. Once a transaction has been settled it can only be refunded. Because payment gateways have different processing times for settling transaction, we will automatically attempt a void before processing a refund. Partial refunds can only be issued on a settled transaction, so please wait 24 hours after an initial transaction has processed before attempting a partial refund."
      li "A voided transaction will typically disappear from a credit/debit account statement within 24 hours, while a refund may take 3 to 5 business days to appear on a credit/debit account statement."
      li "A refund will always be issued to the card used on the original payment."
    end
  end

  # Overriding AA Transactions Controller
  controller do
    def create
      @refund = Transaction.new(refund_params)
      if @refund.valid?
        Monthly::Rapi::Transactions.create_and_refund(@refund)
        Resque.enqueue(RefundInvoiceJob, @refund.id)
        redirect_to admin_refund_path(@refund), flash: { notice: "Refund was successfully created." }
      else
        flash.now[:error] = @refund.errors.full_messages
        render :new
      end
    end

    def refund_params
      params[:refund].slice(:amount, :invoice_id)
    end
  end
end
