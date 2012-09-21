class MoveDetailFieldsFromPlansToMerchants < ActiveRecord::Migration
  def up
  	add_column :plans, :description, :text
  	add_column :plans, :details, :text
  	add_column :plans, :shipping_info, :text

  	# Moving the data from merchants to plans
  	retrieve_merchants.each do |merchant|
  		merchant_id = merchant["id"]
  		retrieve_plans_id(merchant_id).each do |plan_id|
  			update_plan(plan_id, {
	  			description: merchant["general_info"],
	  			details: merchant["details"],
	  			shipping_info: merchant["shipping_info"]
	  		})
  		end
  	end

  	remove_column :merchants, :general_info
  	remove_column :merchants, :shipping_info
  	remove_column :merchants, :details
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

private
	def retrieve_merchants
  	ActiveRecord::Base.connection.execute("SELECT id, shipping_info, general_info, details FROM merchants")
	end

	def retrieve_plans_id(merchant_id)
		sql = "SELECT id FROM plans WHERE merchant_id = #{merchant_id}"
  	ActiveRecord::Base.connection.execute(sql).map {|plan| plan["id"] }
	end

	def update_plan(id, attributes = {})
		set = attributes.to_a.map {|key, val| "#{key} = '#{sanitize_string(val)}'" }.join(', ')
  	ActiveRecord::Base.connection.execute("UPDATE plans SET #{set} WHERE id = #{id}")
	end

	def sanitize_string(s)
		s.to_s.gsub(/\\/, '\&\&').gsub(/'/, "''")
	end
end
