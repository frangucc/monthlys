module RegistrationsHelper

  def tried_this_method_before
    if ['facebook_tries'].present?
      if session['facebook_tries'] >= 1
        return true
      end
    end
    false
  end
end
