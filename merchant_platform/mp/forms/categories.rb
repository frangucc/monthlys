require mp_path('mp/forms/base')
require mp_path('mp/forms/widgets')

module MP
  module Forms
    class CategoryForm < Form
      string :name
      file :image, label: 'Image',
           widget: Bureaucrat::Widgets::ImageInput,
           help_text: 'Maximum size 700kb. JPG, GIF, PNG.'
      file :thumbnail, label: 'Thumbnail',
           widget: Bureaucrat::Widgets::ImageInput,
           help_text: 'Maximum size 700kb. JPG, GIF, PNG.'
      file :icon, label: 'Icon',
           widget: Bureaucrat::Widgets::ImageInput,
           help_text: 'Maximum size 700kb. JPG, GIF, PNG.'
      boolean :is_featured, label: 'Featured', required: false
      field :parent, Bureaucrat::Fields::ModelInstance.new(
                          Category, model_description: :name,
                                    required: false)

      def self.initial_for_parent(value)
        value.id.to_s
      end
    end
  end
end
