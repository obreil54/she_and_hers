class CreateArchives < ActiveRecord::Migration[7.1]
  def change
    create_table :archives do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
