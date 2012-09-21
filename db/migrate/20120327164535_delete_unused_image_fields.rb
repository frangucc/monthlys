class DeleteUnusedImageFields < ActiveRecord::Migration
  def change
    Plan.all.each do |plan|
      raise "There are plan that don't have attachments. Run migration task." if !plan.attachments.any? && !plan.image.blank?
    end
    remove_column :plans, :image
    remove_column :attachments, :thumbnail
    remove_column :attachments, :icon
  end
end
