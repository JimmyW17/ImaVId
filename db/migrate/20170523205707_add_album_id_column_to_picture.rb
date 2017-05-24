class AddAlbumIdColumnToPicture < ActiveRecord::Migration[5.1]
  def change
    add_column :pictures, :album_id, :integer
  end
end
