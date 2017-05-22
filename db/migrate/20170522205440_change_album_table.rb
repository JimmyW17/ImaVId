class ChangeAlbumTable < ActiveRecord::Migration[5.1]
  def change
    remove_column :albums, :name => 'index_albums_on_user_id'
  end
end
