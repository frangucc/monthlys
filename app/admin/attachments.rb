ActiveAdmin.register Attachment do

  actions :index, :show, :edit, :update

  menu :parent => "Plans"

  around_filter &(Monthly::AdminActivityLogger.get_around_filter_block_for('Attachment') do |attachment, attributes|
    attributes.delete(:attachable_id)
    attributes.merge({
      attachable: { id: attachment.attachable_id, desc: attachment.attachable_type }
    })
  end)

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs do
      f.input :image, :as => :file
      f.input :order
      f.input :attachable_id, label: "ID of the plan"
    end
    f.buttons
  end

  index do
    column :id
    column 'Attached to', :attachable
    column :image, sortable: true do |attachment|
      image_tag(attachment.image, style: 'width: 120px;')
    end
    default_actions
  end

  show do
    attributes_table do
      row :id
      row :attachable
      row :order
      row :image do
        image_tag(attachment.image, alt: attachment.id)
      end
    end
  end

end
