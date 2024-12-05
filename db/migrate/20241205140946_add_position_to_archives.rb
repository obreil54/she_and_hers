class AddPositionToArchives < ActiveRecord::Migration[7.1]
  def change
    add_column :archives, :position, :integer
  end
end
