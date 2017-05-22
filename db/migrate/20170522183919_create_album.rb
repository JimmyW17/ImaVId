class CreateAlbum < ActiveRecord::Migration[5.1]
  def change
    create_table :albums do |t|
      t.integer :user_id
    end
  end
end
