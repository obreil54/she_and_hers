class AddPositionToCollaborations < ActiveRecord::Migration[7.1]
  def change
    add_column :collaborations, :position, :integer
  end
end
