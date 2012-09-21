class AddSuperhubPlanVideoUrl < ActiveRecord::Migration
  def change
    add_column(:superhub_plans, :video_url, :string, null: false, default: '')
  end
end
