class AddTagsColumnToPictures < ActiveRecord::Migration[5.1]
  def change
    add_column :pictures, :tags, :text
  end
end
