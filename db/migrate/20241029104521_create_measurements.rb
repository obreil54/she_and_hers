class CreateMeasurements < ActiveRecord::Migration[7.1]
  def change
    create_table :measurements do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :chest
      t.integer :waist
      t.integer :high_hips
      t.integer :low_hips
      t.integer :thigh
      t.integer :torso
      t.integer :arm_length
      t.integer :shoulder_width
      t.integer :upper_arm_circumference
      t.integer :inseam
      t.integer :height

      t.timestamps
    end
  end
end
