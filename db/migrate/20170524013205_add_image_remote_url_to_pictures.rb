class AddImageRemoteUrlToPictures < ActiveRecord::Migration[5.1]
  def change
    add_column :pictures, :picture_remote_url, :string
  end
end
