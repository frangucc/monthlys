class CreateSuperhubTables < ActiveRecord::Migration
  def change

    create_table :superhub_plan_groups do |t|
      t.string(:superhub, limit: 50, default: '', null: false)
      t.string(:title, limit: 200, default: '', null: false)
      t.string(:subtitle, default: '', null: false)
      t.string(:group_type, default: '', null: false)
      t.integer(:ordering, default: 0, null: false)
      t.timestamps
    end

    create_table :superhub_plans do |t|
      t.integer(:plan_id)
      t.integer(:superhub_plan_group_id)
      t.integer(:ordering, default: 0, null: false)
      t.string(:image, default: '', null: false)
      t.timestamps
    end

  end
end
