module CategoriesHelper

  def plan_conditional_path(plan)
    (plan.pending?)? preview_plan_path(plan.unique_hash) : plan_path(plan)
  end

  def ask_for_zipcode?(user)
    !cookies[:zipcode_prompt] &&
    (
      (user && user.zipcode_str.blank?) ||
      (!user && !session[:zipcode_id])
    )
  end
end
