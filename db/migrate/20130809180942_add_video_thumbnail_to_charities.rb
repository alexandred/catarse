class AddVideoThumbnailToCharities < ActiveRecord::Migration
  def change
    add_column :charities, :video_thumbnail, :string
    add_column :charities, :video_embed_url, :string
  end
end
