ActiveAdmin.register Faq do

  menu parent: 'Merchants'

  around_filter &(Monthly::AdminActivityLogger.get_around_filter_block_for('Faq') do |faq, attributes|
    attributes.merge({ merchants: faq.merchants.map {|m| { id: m.id, desc: m.business_name } } })
  end)

  form do |f|
    f.inputs do
      f.input :merchants
      f.input :question
      f.input :answer, hint: 'You may use markdown in this field.'
      f.input :order
    end
    f.buttons
  end

end
