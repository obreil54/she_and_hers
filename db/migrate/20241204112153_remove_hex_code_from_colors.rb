class RemoveHexCodeFromColors < ActiveRecord::Migration[7.1]
  def change
    remove_column :colors, :hex_code, :string
  end
end
