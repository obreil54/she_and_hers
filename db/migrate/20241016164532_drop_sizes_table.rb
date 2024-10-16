class DropSizesTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :sizes
  end
end
