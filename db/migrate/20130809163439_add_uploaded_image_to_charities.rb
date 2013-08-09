class AddUploadedImageToCharities < ActiveRecord::Migration
  def change
    add_column :charities, :uploaded_image, :string
  end
end
