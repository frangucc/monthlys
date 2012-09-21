ActiveAdmin.register Shipment do

  actions :index, :show, :new, :create

  menu parent: 'Subscriptions'

  action_item do
    link_to 'Upload CSV', batch_form_admin_shipments_path
  end

  index do
    column :id do |s|
      link_to s.id, admin_shipments_path(s)
    end
    column :created_at do |s|
      s.created_at.strftime('%m/%d/%Y')
    end
    column :subscription_id do |s|
      link_to s.subscription.id, admin_subscriptions_path(s.subscription)
    end
    column :carrier
    column :tracking_number

    default_actions
  end

  show do
    attributes_table do
      row :id
      row :created_at
      row :subscription_id
      row :carrier
      row :tracking_number
    end

    active_admin_comments
  end

  controller do
    def create
      @shipment = Shipment.new(params[:shipment])
      if @shipment.save
        Resque.enqueue(TrackingNumberJob, @shipment.id)
        redirect_to admin_shipments_path, flash: { notice: 'Shipment created successfully.' }
      else
        render 'new'
      end
    end
  end

  collection_action :batch_form, method: :get do
  end

  collection_action :batch_upload, method: :post do
    require 'csv'
    csv = CSV.parse(params[:uploaded_file].read)
    csv.shift
    shipments = []
    row_number = 2
    all_valid = true
    errors = []
    csv.each do |row|
      shipment = Shipment.new(carrier: row[1], tracking_number: row[2])
      shipment.subscription = Subscription.find_by_id(row[0])

      if shipment.valid?
        shipments << shipment if all_valid
      else
        all_valid = false
        errors.concat(shipment.errors.full_messages.map {|e| "Row ##{row_number}: #{e}." })
      end

      row_number += 1
    end

    if all_valid
      shipments.each do |shipment|
        shipment.save
        Resque.enqueue(TrackingNumberJob, shipment.id)
      end
      redirect_to admin_shipments_path, flash: { notice: "#{shipments.count} shipments created successfully!" }
    else
      redirect_to batch_form_admin_shipments_path, flash: { error: errors }
    end
  end
end
