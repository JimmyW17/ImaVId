class AddColumnToAlbum < ActiveRecord::Migration[5.1]
  def change
    add_column :albums, :user, :belongs_to, index: {unique: true}, foreign_key: true
  end
end
