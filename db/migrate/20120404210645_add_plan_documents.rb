class AddPlanDocuments < ActiveRecord::Migration
  def change
    create_table :plan_documents do |t|
      t.integer(:plan_id)
      t.string(:name)
      t.string(:description)
      t.string(:file)
    end
  end
end
