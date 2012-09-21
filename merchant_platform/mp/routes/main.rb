module MP
  module Routes
    class Main < RoutesBase
      get url(:dashboard, '/') do
        merchant_required!
        redirect(url_for(:plan_list))
      end

      def ajax_model(model_class, look_attr)
        if params[:id]
          entries = model_class.where('id in (?)',
                                      params[:id].split(',').map(&:to_i))
        else
          entries = model_class.where("#{look_attr} ILIKE ?",
                                      "%#{params[:name]}%")
        end

        look_attr = look_attr.to_sym
        json(entries.map{ |e|
          { id: e.id,
            look_attr => e.send(look_attr).titleize.strip }
        })
      end

      get url(:city, '/cities') do
        merchant_required!
        ajax_model(City, 'name')
      end

      get url(:state, '/states') do
        merchant_required!
        ajax_model(State, 'name')
      end

      get url(:zip, '/zipcodes') do
        merchant_required!
        ajax_model(Zipcode, 'number')
      end
    end
  end

  Main.use Routes::Main
end
