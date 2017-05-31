class RemoveImageColsFromUser < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :image_file_name, :boolean
    remove_column :users, :image_content_type, :boolean
    remove_column :users, :image_file_size, :boolean
    remove_column :users, :image_updated_at, :boolean

  end
end
