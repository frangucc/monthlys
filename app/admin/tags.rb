ActiveAdmin.register Tag, as: 'KeywordTag' do

  menu parent: 'Navigation'

  around_filter &(Monthly::AdminActivityLogger.get_around_filter_block_for('Tag', { instance_var_name: 'keyword_tag', find_by: 'slug' }) do |tag, attributes|
    attributes.merge({ plans: tag.plans.map {|p| { id: p.id, desc: p.name } } })
  end)

  before_filter only: [:show, :edit, :update, :destroy] do
    @keyword_tag = Tag.find_by_slug(params[:id])
  end

  filter :keyword
  filter :is_featured, as: :select
  filter :order
  filter :created_at
  filter :updated_at

  index do
    column :id
    column :keyword
    column 'Plans', :plans do |tag|
      tag.plans.map(&:name).join(', ')
    end
    column 'URL', :slug do |tag|
      link_to tag.keyword, tag_path(tag)
    end
    column :is_featured
    column :order
    default_actions
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs do
      f.input :keyword
      f.input :is_featured
      f.input :plans, as: :select, collection: Plan.has_status(:active).order('plans.name ASC').all, class: 'plan-select'
      f.input :header_image, as: :file, hint: 'Header image ideal size: 900x160px. This will show up as a heading for the category group page.'
      f.input :order
    end
    f.buttons
  end
end
