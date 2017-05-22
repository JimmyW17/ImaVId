class RemoveIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index :albums, :user_id
  end
end
