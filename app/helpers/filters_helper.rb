module FiltersHelper
  def plan_type_filter
    [['All', [['All', '']]]] + PlanType.subtypes_by_types.map do |type, subtypes|
      [PlanType.get_all_types[type][:name], subtypes.map {|sub_k, sub_name| [sub_name, sub_k]}]
    end
  end
end
