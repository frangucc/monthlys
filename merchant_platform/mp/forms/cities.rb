require mp_path('mp/forms/base')
require mp_path('mp/forms/widgets')

module MP
  module Forms
    class CityForm < Form
      string :name
      field :state, Bureaucrat::Fields::ModelInstance.new(
                          State, model_description: :name)
      boolean :is_featured, label: 'Featured', required: false
      file :image, label: 'Image',
                   widget: Bureaucrat::Widgets::ImageInput,
                   help_text: 'Maximum size 700kb. JPG, GIF, PNG.'

      def self.initial_for_state(value)
        value.id.to_s
      end
    end
  end
  #  state_code  :string(255)
end
