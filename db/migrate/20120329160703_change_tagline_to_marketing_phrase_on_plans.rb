class ChangeTaglineToMarketingPhraseOnPlans < ActiveRecord::Migration
  def change
  	rename_column :plans, :tagline, :marketing_phrase
  end
end
