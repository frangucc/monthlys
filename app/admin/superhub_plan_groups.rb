ActiveAdmin.register SuperhubPlanGroup do

  menu parent: 'Navigation', label: 'Superhub Groups'

  around_filter &Monthly::AdminActivityLogger.get_around_filter_block_for('SuperhubPlanGroup')

  filter :superhub, as: :select, collection: Superhub.find_all_key_name_hash
  filter :group_type, as: :select, collection: Hash[ SuperhubPlanGroup.get_group_types.map{ |k,v| [v, k] } ]
  filter :title
  filter :subtitle

  index do
    column :id
    column :superhub do |g|
      Superhub.new(g.superhub).verbose_name
    end
    column :title
    column :subtitle
    column :group_type do |g|
      SuperhubPlanGroup.get_group_types[g.group_type.to_sym] || ''
    end
    column :ordering
    default_actions
  end

  show do
    attributes_table do
      row :id
      row :superhub do |g|
        Superhub.new(g.superhub).verbose_name
      end
      row :title
      row :subtitle
      row :group_type do |g|
        SuperhubPlanGroup.get_group_types[g.group_type.to_sym] || ''
      end
      row :ordering
      row :label do |g|
        g.get_label_display || ''
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.inputs 'Details' do
      f.input :superhub, as: :select, collection: Superhub.find_all_key_name_hash, required: true
      f.input :group_type, as: :select, collection: Hash[ SuperhubPlanGroup.get_group_types.map{ |k,v| [v, k] } ], required: true
      f.input :title, required: true
      f.input :subtitle
      f.input :label, as: :select, collection: [ [ 'Featured', :featured ],
                                                 [ 'New', :new ],
                                                 [ 'Local', :local ],
                                                 [ 'Sale', :sale ] ]
      f.input :ordering, required: true
    end
    f.buttons
  end
end
